# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsHeaderCellExtensions
      extend ActiveSupport::Concern
      include ::Decidim::BudgetsBooth::BudgetsControllerHelper

      included do
        delegate :voting_open?, :voting_finished?, :component_settings, to: :controller
        delegate :user_zip_code, to: :scope_manager

        private

        def scope_manager
          @scope_manager ||= ::Decidim::BudgetsBooth::ScopeManager.new
        end
      end
    end
  end
end
