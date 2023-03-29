# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsControllerExtensions
      extend ActiveSupport::Concern
      include ::Decidim::BudgetsBooth::BudgetsControllerHelper

      included do
        layout :determine_layout
        before_action :ensure_authenticated, if: :open_zip_code_workflow?
        before_action :ensure_user_zip_code, if: :open_zip_code_workflow?

        def index
          # we need to redefine this action to avoid redirect in case of single budget
        end

        private

        def determine_layout
          return layout unless zip_code_workflow?

          return layout unless voting_enabled?

          return layout if voted_all_budgets?

          "decidim/budgets/voting_layout"
        end

        def open_zip_code_workflow?
          zip_code_workflow? && voting_open?
        end

        def layout
          current_participatory_space_manifest.context(current_participatory_space_context).layout
        end
      end
    end
  end
end
