# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # This cell has the commons for the budgets cells
    class VoteCompletedCell < Decidim::ViewModel
      def show
        return if vote_completed_content.blank?

        render
      end

      private

      def vote_completed_content
        return unless model.settings
        return unless model.settings.respond_to?(:vote_completed_content)

        translated_attribute(model.settings.vote_completed_content)&.html_safe
      end
    end
  end
end
