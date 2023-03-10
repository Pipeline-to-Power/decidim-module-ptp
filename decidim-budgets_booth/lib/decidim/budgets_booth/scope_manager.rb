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
    end
  end
end
