# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module Workflows
      # This is the zip_code Workflow class.
      class ZipCode < ::Decidim::Budgets::Workflows::Base
        delegate :zip_codes_for, :user_zip_code, to: :scope_manager

        # No budget is highlighted for this workflow
        def highlighted?(_resource)
          false
        end

        def disable_voting_instructions?(_resource)
          true
        end

        def show_image_in_popup?(_resource)
          false
        end

        # User can vote in the resource inside their area where they live. This is being determined
        # by their zip code.
        def vote_allowed?(resource, consider_progress: true) # rubocop:disable Lint/UnusedMethodArgument
          user_zip_code = user_zip_code(user)
          return false if user_zip_code.blank?

          zip_codes_for(resource).include?(user_zip_code)
        end

        def budgets
          super.select { |item| vote_allowed?(item) }
        end

        def voting_booth_forced?
          true
        end

        private

        def scope_manager
          @scope_manager ||= ::Decidim::BudgetsBooth::ScopeManager.new(budgets_component)
        end

        def projects(budget)
          Decidim::Budgets::Project.where(budget: budget)
        end
      end
    end
  end
end
