# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Smsauth
    # This is the engine that runs on the public interface of smsauth.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Smsauth

      routes do
        devise_scope :user do
          # We need to define the routes to be able to show the sign in views
          # within Decidim.
          match(
            "/users/auth/sms",
            to: "omniauth#new",
            via: [:get, :post]
          )

          namespace :users_auth_sms, path: "/users/auth/sms", module: "omniauth" do
            get :edit
            post :update
            post :send_message
            get :resend_code
            get :verification
            post :authenticate_user
            get :registration
            post :user_registry
          end
        end
      end

      initializer "decidim_smsauth.mount_routes", before: :add_routing_paths do
        # Mount the engine routes to Decidim::Core::Engine because otherwise
        # they would not get mounted properly. Note also that we need to prepend
        # the routes in order for them to override Decidim's own routes for the
        # "sms" authentication.
        Decidim::Core::Engine.routes.prepend do
          mount Decidim::Smsauth::Engine => "/"
        end
      end

      initializer "decidim_smsauth.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_smsauth.overrides" do |app|
        app.config.to_prepare do
          Decidim::User.include(Decidim::Smsauth::SmsConfirmableUser)
          # commands
          Decidim::DestroyAccount.include(
            Decidim::Smsauth::DestroyAccountOverrides
          )
          # forms
          Decidim::AccountForm.include(Decidim::Smsauth::AccountFormExtensions)
        end
      end

      # This initializer is only for the tests so that we do not need to modify
      # the secrets and configuration of the application.
      if Rails.env.test?
        initializer "decidim_smsauth.tests", before: :add_routing_paths do
          Rails.application.secrets[:omniauth][:sms] = { enabled: true, icon: "phone" }
        end
      end
    end
  end
end
