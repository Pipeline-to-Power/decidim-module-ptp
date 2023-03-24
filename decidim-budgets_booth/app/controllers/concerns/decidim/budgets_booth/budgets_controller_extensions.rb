# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsControllerExtensions
      extend ActiveSupport::Concern
      include ::Decidim::BudgetsBooth::BudgetsControllerHelper

      included do
        layout :determine_layout
        before_action :ensure_authenticated, if: :zip_code_workflow? && :voting_open?
        before_action :ensre_user_zip_code, if: :zip_code_workflow? && :voting_open?

        def index
          # we need to redefine this action to avoid redirect in case of single budget
        end

        private

        def determine_layout
          return nil unless zip_code_workflow?

          return nil unless voting_enabled?

          return nil if voted_all_budgets?

          "decidim/budgets/voting_layout"
        end
      end
    end
  end
end
