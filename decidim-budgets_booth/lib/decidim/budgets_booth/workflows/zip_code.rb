# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module Workflows
      # This is the zip_code Workflow class.
      class ZipCode < ::Decidim::Budgets::Workflows::Base
        delegate :zip_codes, :user_zip_code, to: :scope_manager
        # Highlight the resource if the user didn't vote and is allowed to vote on it.
        def highlighted?(resource)
          vote_allowed?(resource)
        end

        # User can vote in the resource inside their area where they live. This is being determined
        # by their zip code.
        def vote_allowed?(resource, consider_progress: true) # rubocop:disable Lint/UnusedMethodArgument
          user_zip_code = user_zip_code(user, budgets_component)
          return false if user_zip_code.blank?

          zip_codes(resource).include?(user_zip_code)
        end

        def budgets
          super.select { |item| vote_allowed?(item) }
        end

        private

        def scope_manager
          @scope_manager ||= ::Decidim::BudgetsBooth::ScopeManager.new
        end

        def projects(budget)
          Decidim::Budgets::Project.where(budget: budget)
        end
      end
    end
  end
end