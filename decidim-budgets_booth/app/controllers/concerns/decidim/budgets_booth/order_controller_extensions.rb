# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module OrderControllerExtensions
      extend ActiveSupport::Concern

      included do
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
      end
    end
  end
end
