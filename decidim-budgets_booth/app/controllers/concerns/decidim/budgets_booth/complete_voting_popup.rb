# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module CompleteVotingPopup
      extend ActiveSupport::Concern

      included do
        before_action :completed_vote_snippets
      end

      private

      def completed_vote_snippets
        return if request.xhr?
        return unless respond_to?(:snippets)
        return unless session.delete(:booth_vote_completed)

        component_id = session.delete(:booth_voted_component)
        return unless component_id

        component = Decidim::Component.find(component_id)
        snippets.add(:head, <<~HTML
          <script type="text/template" id="vote-completed-snippet">
            #{cell("decidim/budgets_booth/vote_completed", component)}
          </script>
        HTML
        )
        snippets.add(:head, helpers.javascript_pack_tag("decidim_handle_voting_complete"))
      end
    end
  end
end
