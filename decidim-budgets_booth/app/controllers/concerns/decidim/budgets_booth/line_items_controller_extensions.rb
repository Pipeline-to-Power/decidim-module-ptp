# frozen_string_literal: true

# Customizes the line items controller
module Decidim
  module BudgetsBooth
    module LineItemsControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_action :set_help_modal

        helper Decidim::Budgets::VotingHelper

        private

        def set_help_modal
          @show_help_modal =
            if current_workflow.try(:disable_voting_instructions?)
              false
            else
              Decidim::Budgets::Order.find_by(user: current_user, budget: budget).blank?
            end
        end
      end
    end
  end
end
