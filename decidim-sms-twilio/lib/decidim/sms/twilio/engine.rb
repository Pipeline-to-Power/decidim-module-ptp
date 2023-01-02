# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Sms
    module Twilio
      # This is the engine that runs on the public interface of sms-twilio.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Sms::Twilio

        routes do
          scope "/sms/twilio" do
            post :delivery, to: "deliveries#update"
          end
        end

        initializer "sms_twilio.mount_routes" do
          Decidim::Core::Engine.routes do
            mount Decidim::Sms::Twilio::Engine => "/"
          end
        end

        initializer "sms_twilio.configure_gateway" do
          Decidim.config.sms_gateway_service = "Decidim::Sms::Twilio::Gateway"
        end

        initializer "sms_twilio.webpacker.assets_path" do
          Decidim.register_assets_path File.expand_path("app/packs", root)
        end
      end
    end
  end
end
