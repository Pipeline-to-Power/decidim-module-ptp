# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsControllerExtensions
      extend ActiveSupport::Concern
      include ::Decidim::BudgetsBooth::VotingSupport

      included do
        layout :determine_layout
        before_action :ensure_authenticated, if: :open_and_voting_booth_forced?
        before_action :ensure_user_zip_code, if: :open_and_voting_booth_forced?
        before_action :ensure_multiple_budgets

        def index
          # we need to redefine this action to avoid redirect in case of single budget
        end

        private

        def determine_layout
          return layout unless voting_booth_forced?

          return layout unless voting_enabled?

          return layout if voted_all_budgets?

          "decidim/budgets/voting_layout"
        end

        def open_and_voting_booth_forced?
          voting_booth_forced? && voting_open?
        end

        def layout
          current_participatory_space_manifest.context(current_participatory_space_context).layout
        end
      end
    end
  end
end
