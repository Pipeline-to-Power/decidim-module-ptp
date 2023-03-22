# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    class ZipCode < ::Decidim::Budgets::Workflows::Base
      include ScopeManager
      # Highlight the resource if the user didn't vote and is allowed to vote on it.
      def highlighted?(resource)
        vote_allowed?(resource)
      end

      # User can vote in the resource inside their area where they live. This is being determined
      # by their zip code.
      def vote_allowed?(resource, consider_progress: true) # rubocop:disable Lint/UnusedMethodArgument
        return false unless user_zip_code(user, budgets_component)

        return false unless zip_codes(projects(resource)).include?(user_zip_code(user, budgets_component))

        true
      end

      def budgets
        super.select { |item| vote_allowed?(item) }
      end

      private

      def projects(budget)
        Decidim::Budgets::Project.where(budget: budget)
      end
    end
  end
end
