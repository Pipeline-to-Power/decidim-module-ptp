# frozen_string_literal: true

module Decidim
  module Sms
    module Twilio
      class DeliveriesController < Decidim::Sms::Twilio::ApplicationController
        include Decidim::Sms::Twilio::TokenGenerator

        skip_before_action :verify_authenticity_token

        def update
          callback_token = params[:token]
          raise Decidim::ActionForbidden unless token_match?(callback_token)

          update_status
        end

        private

        def token_match?(callback_token)
          generate_token(current_organization.host) == callback_token
        end

        def update_status
          response = JSON.parse(request.body.read)
          delivery = Delivery&.find_by(sid: response[:sid])
          delivery.update(status: response[:status])
        end
      end
    end
  end
end
