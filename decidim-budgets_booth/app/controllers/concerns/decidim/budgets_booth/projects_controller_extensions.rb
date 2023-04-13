# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectsControllerExtensions
      extend ActiveSupport::Concern
      include BudgetsControllerHelper

      included do
        def index
          raise ActionController::RoutingError, "Not Found" unless budget

          raise ActionController::RoutingError, "Not Found" unless allow_access?
        end

        def show
          raise ActionController::RoutingError, "Not Found" unless budget
          raise ActionController::RoutingError, "Not Found" unless project
          raise ActionController::RoutingError, "Not Found" if zip_code_workflow? && voting_enabled?
        end
      end

      private

      def allow_access?
        return false if zip_code_workflow? && voting_enabled? && !voted_all_budgets?

        true
      end
    end
  end
end
