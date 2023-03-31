# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ScopeManager
      def zip_codes(resource)
        return [] if resource.scope.blank?

        result = Set.new
        process_subscopes(resource.scope, result)
        result.to_a.uniq
      end

      private

      def process_subscopes(scope, result)
        scope.children.each do |subscope|
          if subscope.children.any?
            process_subscopes(subscope, result)
          else
            postal = zip_code(subscope)
            result.add(postal)
          end
        end
      end

      def zip_code(scope)
        scope.code.split("_").last
      end

      def user_zip_code(user, budgets_component)
        return false if user.blank?

        user_data = user.budgets_user_data.find_by(component: budgets_component)
        user_data&.metadata
      end

      def budget_scope_type(budget)
        type = translated_attribute(budget&.scope&.scope_type&.name)
        return if type.blank?

        type.split.last
      end
    end
  end
end
