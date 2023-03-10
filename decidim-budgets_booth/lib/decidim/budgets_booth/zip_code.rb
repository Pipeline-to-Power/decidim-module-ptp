# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    class ZipCodeWorkflow < ::Decidim::Budgets::Workflows::Base
      include ScopeManager
      # Highlight the resource if the user didn't vote and is allowed to vote on it.
      def highlighted?(resource)
        vote_allowed?(resource)
      end

      # User can vote in the resource where they have an order in progress or in the randomly selected resource.
      def vote_allowed?(resource, _consider_progress: true)
        return false unless user_zip_code

        zip_codes(projects(resource)).include?(user_zip_code)
      end

      private

      def projects(budget)
        Decidim::Budgets::Project.where(budget: budget)
      end

      def user_zip_code
        user_data = user.budgets_user_data.find_by(component: budgets_component)
        user_data.metadata
      end
    end
  end
end
