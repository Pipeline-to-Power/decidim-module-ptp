# frozen_string_literal: true

require "decidim/budgets_booth/engine"
require "decidim/budgets_booth/workflows"

module Decidim
  # This namespace holds the logic of the `BudgetsBooth` component. This component
  # allows users to create budgets_booth in a participatory space.
  module BudgetsBooth
    autoload :VotingSupport, "decidim/budgets_booth/voting_support"
    autoload :ScopeManager, "decidim/budgets_booth/scope_manager"
    include ActiveSupport::Configurable
    # Default configuration digits to generate the zip code.
    config_accessor :zip_code_length do
      5
    end
  end
end
