# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module BudgetsBooth
    module ScopeManageable
      extend ActiveSupport::Concern

      included do
        after_save :clear_budgets_booth_cache
        after_destroy :clear_budgets_booth_cache
      end

      private

      def clear_budgets_booth_cache
        Decidim::BudgetsBooth::ScopeManager.clear_cache!
      end
    end
  end
end
