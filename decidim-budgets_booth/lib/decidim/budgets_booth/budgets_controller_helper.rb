# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsControllerHelper
      delegate :voted, :voted?, to: :current_workflow

      private

      def zip_code_workflow?
        current_component.settings.workflow == "zip_code"
      end

      def voting_enabled?
        current_component.current_settings.votes == "enabled"
      end

      def ensure_authenticated
        return true if current_user

        flash[:warning] = t(".login_before_access")
        redirect_to decidim.new_user_session_path
      end

      def ensre_user_zip_code
        return true if current_user.try(:budgets_user_data).present?

        flash[:warning] = t(".set_zip_code_before_access")
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

      def ensure_zip_code_workflow
        return true if zip_code_workflow?

        flash[:warning] = t(".not_allowed")
        redirect_to decidim.root_path
      end

      def ensure_not_voted
        return true unless voted_any?

        flash[:warning] = t(".change_zip_code_after_vote")
        redirect_to decidim_budgets.budgets_path
      end

      def voted_all_budgets?
        current_workflow.budgets.map do |budget|
          return false unless voted?(budget)
        end
        true
      end
    end
  end
end
