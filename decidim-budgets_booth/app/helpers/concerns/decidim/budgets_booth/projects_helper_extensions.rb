# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # Customizes the projects helper
    module ProjectsHelperExtensions
      delegate :progress?, to: :current_workflow

      def voting_mode?
        false
      end

      def thanks_popup?
        session[:thanks_message] == true
      end

      def handle_thanks_popup
        remove_thanks_session if thanks_popup?
      end

      def remove_thanks_session
        session.delete(:thanks_message)
      end

      def thanks_text
        translated_attribute(component_settings.try(:thanks_text)).presence || t("decidim.budgets.voting.thanks_message_modal.default_text")
      end

      def i18n_scope
        "decidim.budgets.projects.pre_voting_budget_summary.pre_vote"
      end

      def vote_text
        key = if current_workflow.vote_allowed?(budget) && progress?(budget)
                :finish_voting
              else
                :start_voting
              end

        t(key, scope: i18n_scope)
      end

      def description_text
        key = if current_workflow.vote_allowed?(budget) && progress?(budget)
                :finish_description
              else
                :start_description
              end
        t(key, scope: i18n_scope)
      end

      def budgets_accessible?
        !voting_mode? && budgets_count > 1
      end

      def budgets_count
        Decidim::Budgets::Budget.where(component: current_component).count
      end
    end
  end
end
