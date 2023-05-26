# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    class ScopeManager
      attr_reader :component, :top_scope

      class << self
        # This method allows storing the scopes mappings locally so that they do
        # not have to be re-fetched for the multiple instances of the
        # ScopeManager class.
        def scopes_mapping_for(scope)
          scopes_mapping_cache[scope.id] ||= Rails.cache.fetch(
            "#{cache_key_prefix}/#{scope.cache_key_with_version}",
            expires_in: 1.hour
          ) { generate_scopes_mapping_for(scope) }
        end

        # Allow clearing the cache, useful for the specs.
        def clear_cache!
          scopes_mapping_cache.keys.each do |id|
            scope = Decidim::Scope.find(id)
            Rails.cache.delete("#{cache_key_prefix}/#{scope.cache_key_with_version}")
          rescue ActiveRecord::RecordNotFound
            # If the record was not found, cache key cannot be regenerated, so
            # deleting the old cache record can be omitted.
          end
          @scopes_mapping_cache = {}
        end

        def mark_user_updated!(user)
          Rails.cache.write(cache_key("#{user.id}/updated"), Time.zone.now, expires_in: 1.hour)
        end

        def user_updated_after?(user, time)
          return true if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)

          updated_at = Rails.cache.read(cache_key("#{user.id}/updated"))
          return false unless updated_at

          time > updated_at
        end

        private

        def cache_key_prefix
          "decidim/budgets_booth/scopes_mapping"
        end

        def cache_key(key)
          "#{cache_key_prefix}/#{key}"
        end

        # Stores the local cache of the scopes mappings.
        def scopes_mapping_cache
          @scopes_mapping_cache ||= {}
        end

        # Generates the scopes mapping for the given top-level scope.
        def generate_scopes_mapping_for(scope)
          locale = scope.organization.default_locale
          table = Decidim::Scope.table_name
          connection = ActiveRecord::Base.connection
          columns = "id, parent_id, code, name->>#{connection.quote(locale)} AS name"
          topquery = "SELECT %columns% FROM #{table} WHERE parent_id = #{connection.quote(scope.id)}"
          queries = []

          # Maximum of 3 levels below the top scope:
          #   Boroughs -> Neighborhoods -> Postal codes
          #
          # The postal codes are defined at the deepest level regardless of the
          # amount of levels.
          subquery = topquery
          3.times do |i|
            queries << subquery.sub("%columns%", "#{columns}, #{i} AS depth")
            subquery = "SELECT %columns% FROM #{table} WHERE parent_id IN (#{subquery.sub("%columns%", "id")})"
          end

          # Query all the levels and store the postal code mapping. Note that
          # the order by depth is important for the further processing. The
          # lowest depth needs to be processed first.
          result = connection.select_all("#{queries.join(" UNION ALL ")} ORDER BY depth, name").to_a

          zip_codes_hash(scope, result)
        end

        # Converts the multi-level query results into a flat hash which has the
        # scope IDs as keys and their related ZIP codes as values. This approach
        # allows quickly fetching the ZIP codes for each scope.
        def zip_codes_hash(parent_scope, result)
          max_depth = result.pluck("depth").max
          parents = { parent_scope.id => [] }

          {}.tap do |mapping|
            result.each do |item|
              if item["depth"] == max_depth
                # Postal code
                mapping[item["parent_id"]] ||= []
                mapping[item["parent_id"]] << item["name"]

                each_item(parents, item["parent_id"]) do |parent_id|
                  mapping[parent_id] ||= []
                  mapping[parent_id] << item["name"]
                end
              elsif item["depth"].positive?
                parents[item["id"]] ||= []
                parents[item["id"]] << item["parent_id"] unless parents[item["id"]].include?(item["parent_id"])

                each_item(parents, item["parent_id"]) do |parent_id|
                  parents[item["id"]] << parent_id unless parents[item["id"]].include?(parent_id)
                end
              end
            end
          end
        end

        # This is a helper method to reduce the cyclomatic complexity of the
        # `zip_codes_hash` method.
        def each_item(parents, id)
          return unless parents[id]

          parents[id].each { |parent_id| yield parent_id }
        end
      end

      def initialize(component)
        @component = component
        @top_scope = component.scope
      end

      def zip_codes_for(resource)
        return [] unless top_scope

        scope = scope_for(resource)
        return [] if scope.blank?
        return scopes_mapping.values.flatten.uniq if scope == top_scope

        scopes_mapping[scope.id]&.uniq || []
      end

      def user_zip_code(user)
        return nil if user.blank?

        user_data_for(user)["zip_code"]
      end

      private

      # Stores the component specific user data in a cached variable for faster
      # fetching on consecutive fetches. Fetching the data is slow because it is
      # decrypted, so we need to store it temporarily for faster access.
      def user_data_cache
        @user_data_cache ||= {}
      end

      # Loads the metadata for a specific user from the user data records. If
      # the cache clear method has been called after the user data was loaded
      # (e.g. the data was deleted or updated at the same process), this will
      # reload the data accordingly.
      def user_data_for(user)
        user_data_cache.delete(user.id) if self.class.user_updated_after?(user, Time.zone.now)

        user_data_cache[user.id] ||= begin
          user_data = user.budgets_user_data.find_by(component: component)
          user_data&.metadata || {}
        end
      end

      def scope_for(resource)
        return resource if resource.is_a?(Decidim::Scope)

        resource.scope
      end

      def scopes_mapping
        self.class.scopes_mapping_for(top_scope)
      end
    end
  end
end
