# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # Customizes the projects helper
    module ProjectsHelperExtensions
      delegate :progress?, to: :current_workflow

      def cuurent_phase
        Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(current_organization)
                                                                           .query
                                                                           .where(slug: params[:participatory_process_slug])
                                                                           .first
                                                                           .active_step
                                                                           .title
      end

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

      def thanks_content
        translated_attribute(component_settings.try(:thanks_content)).presence || t("decidim.budgets.voting.thanks_message_modal.default_text")
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
