# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsHelper
      delegate :budgets, :voted, :voted?, to: :current_workflow

      def voting_booth_forced?
        current_workflow.try(:voting_booth_forced?)
      end

      def voting_enabled?
        current_component.current_settings.votes == "enabled"
      end

      def ensure_authenticated
        return true if current_user

        flash[:warning] = t("login_before_access", scope: "decidim.budgets.budgets.index")
        redirect_to decidim.new_user_session_path
      end

      def ensure_user_zip_code
        return true if current_user.try(:budgets_user_data).present?

        redirect_to decidim_budgets.new_zip_code_path
      end

      def decidim_budgets
        @decidim_budgets ||= Decidim::EngineRouter.main_proxy(current_component)
      end

      def voted_any?
        current_user && voted.any?
      end

      def status(budget)
        @status ||= current_workflow.status(budget)
      end

      def ensure_voting_booth_forced
        return true if voting_booth_forced?

        flash[:warning] = t("not_allowed", scope: "decidim.budgets.budgets.index")
        redirect_to decidim.root_path
      end

      def ensure_not_voted
        return true unless voted_any?

        flash[:warning] = t("change_zip_code_after_vote", scope: "decidim.budgets.user_data.new")
        redirect_to decidim.root_path
      end

      # maximum_budgets_to_vote_on is being set by the admin. the default is zero, which means users can
      # vote in all available budgets. to check that user has voted to all available budgets, we should
      # consider this settings as well.
      def voted_all_budgets?
        default_limit = current_component.settings.maximum_budgets_to_vote_on
        available_budgets = budgets.count
        vote_limit = if default_limit.zero?
                       available_budgets
                     else
                       [default_limit, available_budgets].min
                     end
        return false if voted.count < vote_limit

        true
      end

      # This configuration option can be set in component settings, the dfault url when the user has voted on all budgets
      # is budgets path
      def success_redirect_path
        component_settings.try(:vote_success_url).presence || decidim_budgets.budgets_path
      end

      # This configuration option can be set in component settings, the dfault url when the user cancels voting is the root path.
      def cancel_redirect_path
        component_settings.try(:vote_cancel_url).presence || decidim.root_path
      end

      def hide_unvoted?(budget)
        return false unless voting_open?

        return false if voted_this?(budget)

        return false unless voted_all_budgets?

        true
      end

      def voted_this?(budget)
        current_workflow.status(budget) == :voted
      end
    end
  end
end
