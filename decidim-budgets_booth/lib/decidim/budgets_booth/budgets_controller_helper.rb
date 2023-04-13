# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsControllerHelper
      delegate :voted, :voted?, to: :base_workflow

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

        flash[:warning] = t("set_zip_code_before_access", scope: "decidim.budgets.budgets.index")
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

      def voted_all_budgets?
        budgets = current_workflow.budgets
        return false if budgets.blank?

        budgets.map do |budget|
          return false unless voted?(budget)
        end
        true
      end

      # This configuration option can be set in component settings, the dfault url when the user has voted on all budgets
      # is budgets path
      def success_redirect_path
        component_settings.try(:vote_success_url).presence || budgets_path
      end

      # This configuration option can be set in component settings, the dfault url when the user cancels voting is the root path.
      def cancel_redirect_path
        component_settings.try(:vote_cancel_url).presence || decidim.root_path
      end

      def base_workflow
        @base_workflow ||= Decidim::Budgets::Workflows::Base.new(current_component, current_user)
      end
    end
  end
end
