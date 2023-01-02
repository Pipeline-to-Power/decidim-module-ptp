# frozen_string_literal: true

# A Service to send SMS to Twilio provider to make capability of sending sms with Twilio gateway
module Decidim
  module Sms
    class GatewayError < StandardError
      attr_reader :error_code

      def initialize(message = "Gateway error", error_code = :unknown)
        @error_code = error_code
        super(message)
      end
    end

    module Twilio
      class TwilioGatewayError < GatewayError
        def initialize(message = "Gateway error", error_code = 0)
          super(message, twilio_error(error_code))
        end

        private

        def twilio_error(twilio_code)
          case twilio_code
          when 21_211
            :invalid_to_number
          when 21_408
            :invalid_geo_permission
          when 21_606
            :invalid_from_number
          else
            # Please check the logs for more information on these errors.
            :unknown
          end
        end
      end

      class Gateway
        include TokenGenerator

        attr_reader :phone_number, :code

        def initialize(phone_number, code, organization: nil)
          @phone_number = phone_number
          @code = code
          @organization = organization
          @account_sid ||= Rails.application.secrets.twilio[:twilio_account_sid]
          @auth_token ||= Rails.application.secrets.twilio[:twilio_auth_token]
          @twilio_sender ||= Rails.application.secrets.twilio[:twilio_sender]
        end

        def deliver_code
          track_delivery do |delivery|
            create_message!

            response = client.http_client.last_response

            if response
              delivery.update!(
                to: response.body["to"],
                sid: response.body["sid"],
                status: response.body["status"]
              )
            end
          end

          true
        rescue ::Twilio::REST::RestError => e
          Rails.logger.error "Twilio::REST::RestError -- Twilio failed to deliver the code"
          Rails.logger.error "Twilio Error: #{e.code}"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")

          raise TwilioGatewayError.new(e.message, e.code)
        end

        private

        attr_reader :organization

        def client
          @client ||= ::Twilio::REST::Client.new(@account_sid, @auth_token)
        end

        def create_message!
          options = {}.tap do |opt|
            opt[:body] = @code
            opt[:from] = @twilio_sender
            opt[:to] = @phone_number
            if @organization
              opt[:status_callback] = Decidim::EngineRouter.new(
                "decidim_sms_twilio",
                { host: @organization.host }
              ).delivery_url(token: generate_token(@organization.host))
            end
          end
          client.messages.create(options)
        end

        def track_delivery
          yield Delivery.create(
            from: @twilio_sender,
            to: @phone_number,
            body: @code,
            status: ""
          )
        end
      end
    end
  end
end
