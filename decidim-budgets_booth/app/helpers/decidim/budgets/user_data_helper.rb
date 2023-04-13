# frozen_string_literal: true

module Decidim
  module Budgets
    module UserDataHelper
      delegate :user_zip_code, to: :scope_manager

      def voting_terms
        translated_attribute(component_settings.try(:voting_terms)).presence
      end

      def zip_code_length
        ::Decidim::BudgetsBooth.zip_code_length.to_i
      end

      # we need to redirect user to the root path if they
      # want to candel the user_data entering, and they don't have a zip code. otherwise we
      # get into infinit redirect loop, since the budgets index path redirects users
      # to this view if they dont have a zip code.
      def cancel_redirect_path
        if user_zip_code(current_user, current_component)
          decidim_budgets.budgets_path
        else
          decidim.root_path
        end
      end


      # def voted_all_budgets?
      #   return false if budgets.blank?

      #   max_allowed_votes = budgets_component.settings.maximum_budgets_to_vote_on
      #   return true if max_allowed_votes.positive? && voted.count >= max_allowed_votes

      #   budgets.map do |budget|
      #     return false unless voted?(budget)
      #   end
      #   true
      # end

      private

      def scope_manager
        @scope_manager ||= ::Decidim::BudgetsBooth::ScopeManager.new
      end
    end
  end
end
