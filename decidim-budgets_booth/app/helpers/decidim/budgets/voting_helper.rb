# frozen_string_literal: true

module Decidim
  module Budgets
    module VotingHelper
      def voting_mode?
        true
      end

      def authorization_providers
        Verifications::Adapter.from_collection(
          available_authorization_provider_keys - user_authorizations.pluck(:name)
        )
      end
    end
  end
end
