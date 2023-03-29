# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectsControllerExtensions
      extend ActiveSupport::Concern
      include BudgetsControllerHelper

      included do
        before_action :enforce_open_zip_code

        def index
          raise ActionController::RoutingError, "Not Found" unless budget
        end

        def show
          raise ActionController::RoutingError, "Not Found" unless budget
          raise ActionController::RoutingError, "Not Found" unless project
        end

        private

        def enforce_open_zip_code
          return true unless zip_code_workflow? && voting_enabled?

          redirect_to decidim_budgets.budget_voting_index_path(budget)
        end
      end
    end
  end
end
