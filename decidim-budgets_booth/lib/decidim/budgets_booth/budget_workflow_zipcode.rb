# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    class BudgetWorkflowZipcode < Decidim::Budgets::Workflows::Base
      # Highlight the resource if the user didn't vote and is allowed to vote on it.
      def highlighted?(resource)
        vote_allowed?(resource)
      end

      # User can vote in the resource where they have an order in progress or in the randomly selected resource.
      def vote_allowed?(resource, consider_progress: true)
       # TODO: add workflow for this
      end
    end
  end
end
