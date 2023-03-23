# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsHeaderCellExtensions
      extend ActiveSupport::Concern
      include ::Decidim::BudgetsBooth::BudgetsControllerHelper

      included do
        delegate :voting_open?, :voting_finished?, :component_settings, to: :controller
      end
    end
  end
end
