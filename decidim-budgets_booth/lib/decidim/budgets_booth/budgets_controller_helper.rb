# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsControllerHelper
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
    end
  end
end
