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

        def handle_user_redirect
          if voted_all_budgets?
            redirect_to success_redirect_path
          else
            redirect_to budgets_path
          end
        end
      end
    end
  end
end
