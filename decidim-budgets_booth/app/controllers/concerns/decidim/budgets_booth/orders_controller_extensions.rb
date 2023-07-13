# frozen_string_literal: true

# Customizes the line items controller
module Decidim
  module BudgetsBooth
    module OrdersControllerExtensions
      include ::Decidim::BudgetsBooth::VotingSupport
      extend ActiveSupport::Concern

      included do
        helper_method :budget

        def checkout
          enforce_permission_to :vote, :project, order: current_order, budget: budget, workflow: current_workflow
          Decidim::Budgets::Checkout.call(current_order) do
            on(:ok) do
              handle_user_redirect
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("orders.checkout.error", scope: "decidim")
              redirect_to decidim_budgets.budgets_path
            end
          end
        end

        def show
          raise ActionController::RoutingError, "Not Found" unless order

          respond_to do |format|
            format.html { redirect_to decidim_budgets.budgets_path }
            format.js { render }
          end
        end

        private

        def handle_user_redirect
          if voted_all_budgets?
            session[:vote_completed] = true
            session[:voted_component] = current_component.id
            redirect_to success_redirect_path
          else
            session[:thanks_message] = true
            redirect_to decidim_budgets.budgets_path
          end
        end

        def order
          result = Decidim::Budgets::Order.find_by(decidim_budgets_budget_id: params[:budget_id])
          return nil unless result && result.checked_out_at.present?

          result
        end
      end
    end
  end
end
