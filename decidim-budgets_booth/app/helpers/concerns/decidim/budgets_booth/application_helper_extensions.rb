# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # Customizes the application helper
    module ApplicationHelperExtensions
      def vote_completed_popup?
        session[:vote_completed] == true
      end

      def handle_vote_completed_session
        session.delete(:vote_completed)
        session.delete(:voted_component)
      end

      def component_settings
        component = Decidim::Component.find(session[:voted_component])
        return if component.blank?

        component.settings
      end

      def vote_completed_content
        translated_attribute(component_settings.try(:vote_completed_content))&.html_safe
      end
    end
  end
end
