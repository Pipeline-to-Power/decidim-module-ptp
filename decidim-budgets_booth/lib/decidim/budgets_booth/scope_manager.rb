# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ScopeManager
      def zip_codes(resources)
        result = []
        resources.map(&:scope).each do |scope|
          postal = zip_code(scope)
          next if result.include?(postal)

          result << postal
        end
        result
      end

      def zip_code(scope)
        scope.code.split("_").last
      end

      def user_zip_code(user, budgets_component)
        user_data = user.budgets_user_data.find_by(component: budgets_component)
        user_data.metadata
      end
    end
  end
end
