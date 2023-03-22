# frozen_string_literal: true

# Customizes the line items controller
module Decidim
  module BudgetsBooth
    module OrdersControllerExtensions
      include ::Decidim::BudgetsBooth::BudgetsControllerHelper
      extend ActiveSupport::Concern

      included do
        def checkout
          enforce_permission_to :vote, :project, order: current_order, budget: budget, workflow: current_workflow

          Decidim::Budgets::Checkout.call(current_order) do
            on(:ok) do
              session[:thanks_message] = true
              handle_user_redirect
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("orders.checkout.error", scope: "decidim")
              redirect_to budgets_path
            end
          end
        end

        private

        def redirect_path
          case params[:return_to]
          when "budget"
            budget_path(budget)
          when "homepage"
            decidim.root_path
          else
            budgets_path
          end
        end

        def handle_user_redirect
          if voted_all_budgets?
            redirect_to component_settings.try(:vote_success_url).presence || budgets_path
          else
            redirect_to budgets_path
          end
        end

        # def voted_all_budgets?
        #   current_workflow.budgets.map do |budget|
        #     return false unless voted?(budget)
        #   end
        #   true
        # end

        # def voted?(resource)
        #   current_user && status(resource) == :voted
        # end

        # def status(budget)
        #   @status ||= current_workflow.status(budget)
        # end
      end
    end
  end
end
