# frozen_string_literal: true

# Customizes the line items controller
module Decidim
  module BudgetsBooth
    module OrdersControllerExtensions
      extend ActiveSupport::Concern

      included do
        def checkout
          enforce_permission_to :vote, :project, order: current_order, budget: budget, workflow: current_workflow

          Decidim::Budgets::Checkout.call(current_order) do
            on(:ok) do
              session[:thanks_message] = true
              redirect_to budgets_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("orders.checkout.error", scope: "decidim")
              redirect_to budgets_path
            end
          end
        end
      end
    end
  end
end
