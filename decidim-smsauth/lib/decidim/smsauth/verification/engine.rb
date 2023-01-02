# frozen_string_literal: true

module Decidim
  module Smsauth
    module Verification
      # This is an engine that authorizes users by sending them a code through
      # an SMS. Different from the core "sms" authorization method.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Smsauth::Verification

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :authorizations, only: [:new, :create, :edit, :update, :destroy], as: :authorization do
            get :resend_code, on: :collection
            get :renew, on: :collection
          end

          root to: "authorizations#new"
        end

        initializer "decidim_smsauth.verification_workflow", after: :load_config_initializers do |_app|
          next unless Decidim.sms_gateway_service

          # We cannot use the name `:smsauth` for the verification workflow
          # because otherwise the route namespace (decidim_smsauth) would
          # conflict with the main engine controlling the authentication flows.
          # The main problem that this would bring is that the root path for
          # this engine would not be found.
          Decidim::Verifications.register_workflow(:smsauth_id) do |workflow|
            workflow.engine = Decidim::Smsauth::Verification::Engine
          end
        end
      end
    end
  end
end
