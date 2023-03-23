# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectsControllerExtensions
      extend ActiveSupport::Concern
      include BudgetsControllerHelper

      included do
        def index
          raise ActionController::RoutingError, "Not Found" unless budget

          raise ActionController::RoutingError, "Not Found" if zip_code_workflow? && voting_enabled?
        end

        def show
          raise ActionController::RoutingError, "Not Found" unless budget
          raise ActionController::RoutingError, "Not Found" unless project
          raise ActionController::RoutingError, "Not Found" if zip_code_workflow? && voting_enabled?
        end
      end
    end
  end
end
