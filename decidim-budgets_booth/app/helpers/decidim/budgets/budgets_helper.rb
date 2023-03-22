# frozen_string_literal: true

module Decidim
  module Budgets
    module BudgetsHelper
      include ::Decidim::BudgetsBooth::BudgetsControllerHelper
      def thanks_popup?
        session[:thanks_message] == true
      end

      def handle_thanks_popup
        remove_thanks_session if thanks_popup?
      end

      def remove_thanks_session
        session.delete(:thanks_message)
      end

      def vote_success_content
        translated_attribute(component_settings.try(:vote_success_content)).presence || t("decidim.budgets.voting.thanks_message_modal.default_text")
      end

      def vote_completed_content
        translated_attribute(component_settings.try(:vote_completed_content)).presence || t("decidim.budgets.voting.vote_completed_modal.default_text")
      end
    end
  end
end
