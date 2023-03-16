# frozen_string_literal: true

require "decidim/budgets_booth/engine"

module Decidim
  # This namespace holds the logic of the `BudgetsBooth` component. This component
  # allows users to create budgets_booth in a participatory space.
  module BudgetsBooth
    autoload :ZipCode, "decidim/budgets_booth/zip_code"
    autoload :ScopeManager, "decidim/budgets_booth/scope_manager"
    autoload :BudgetsControllerHelper, "decidim/budgets_booth/budgets_controller_helper"
  end
end
