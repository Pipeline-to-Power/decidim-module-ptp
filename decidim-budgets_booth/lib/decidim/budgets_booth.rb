# frozen_string_literal: true

require "decidim/budgets_booth/engine"
require "decidim/budgets_booth/scope_manager"
require_relative "budgets_booth/workflows"

module Decidim
  # This namespace holds the logic of the `BudgetsBooth` component. This component
  # allows users to create budgets_booth in a participatory space.
  module BudgetsBooth
    autoload :BudgetsControllerHelper, "decidim/budgets_booth/budgets_controller_helper"
  end
end
