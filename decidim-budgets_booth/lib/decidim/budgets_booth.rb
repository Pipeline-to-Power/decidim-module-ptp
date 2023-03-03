# frozen_string_literal: true

require "decidim/budgets_booth/engine"

module Decidim
  # This namespace holds the logic of the `BudgetsBooth` component. This component
  # allows users to create budgets_booth in a participatory space.
  module BudgetsBooth
    autoload :BudgetWorkflowZipcode, "decidim/budgets_booth/budget_workflow_zipcode"
  end
end
