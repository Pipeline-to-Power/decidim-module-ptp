# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    class ScopeManager
      attr_reader :component, :top_scope

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

        user_data = user.budgets_user_data.find_by(component: component)
        user_data&.metadata&.[]("zip_code")
      end

      private

      def scope_for(resource)
        return resource if resource.is_a?(Decidim::Scope)

        resource.scope
      end

      def scopes_mapping
        @scopes_mapping ||= begin
          locale = top_scope.organization.default_locale
          table = Decidim::Scope.table_name
          connection = ActiveRecord::Base.connection
          columns = "id, parent_id, code, name->>#{connection.quote(locale)} AS name"
          topquery = "SELECT %columns% FROM #{table} WHERE parent_id = #{connection.quote(top_scope.id)}"
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

          zip_codes_hash(result)
        end
      end

      # Converts the multi-level query results into a flat hash which has the
      # scope IDs as keys and their related ZIP codes as values. This approach
      # allows quickly fetching the ZIP codes for each scope.
      def zip_codes_hash(result)
        max_depth = result.pluck("depth").max
        parents = { top_scope.id => [] }

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
  end
end
