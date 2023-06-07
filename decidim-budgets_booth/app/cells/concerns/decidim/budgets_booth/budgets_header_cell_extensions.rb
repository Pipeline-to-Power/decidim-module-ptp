# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsHeaderCellExtensions
      extend ActiveSupport::Concern
      include ::Decidim::BudgetsBooth::VotingSupport

      included do
        delegate :voting_open?, :voting_finished?, :component_settings, :current_workflow, to: :controller
        delegate :user_zip_code, to: :current_workflow
      end
    end
  end
end
