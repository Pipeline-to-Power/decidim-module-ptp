# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    class ScopeManager
      def zip_codes(resource)
        return [] if resource.scope.blank?

        result = Set.new
        process_subscopes(resource.scope, result)
        result.to_a.uniq
      end

      def user_zip_code(user, budgets_component)
        return nil if user.blank?

        user_data = user.budgets_user_data.find_by(component: budgets_component)
        user_data&.metadata&.[]("zip_code")
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
    end
  end
end
