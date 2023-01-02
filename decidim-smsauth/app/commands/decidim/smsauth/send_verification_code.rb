# frozen_string_literal: true

module Decidim
  module Smsauth
    # A command with all the business to add new line items to orders
    class SendVerificationCode < Decidim::Command
      def initialize(form, organization: nil)
        @form = form
        @organization = organization
      end

      # Sends the verification code on a valid form
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        begin
          # result = send_verification!
          # generate_sessions!(result) if result
          # broadcast(:ok)
          result = send_verification!
          return broadcast(:invalid, @gateway_error_code) unless result

          broadcast(:ok, result)
        end
      end

      private

      attr_reader :form, :organization

      def send_verification!
        gateway.deliver_code

        gateway.code
      rescue Decidim::Sms::GatewayError => e
        @gateway_error_code = e.error_code

        false
      end

      def gateway
        @gateway ||=
          begin
            phone_number = phone_with_country_code(form.phone_country, form.phone_number)
            code = generate_code
            if Decidim.config.sms_gateway_service == "Decidim::Sms::Twilio::Gateway"
              Decidim.config.sms_gateway_service.constantize.new(phone_number, code, organization: organization)
            else
              Decidim.config.sms_gateway_service.constantize.new(phone_number, code)
            end
          end
      end

      def generate_code
        SecureRandom.random_number(10_000_000).to_s
      end

      def phone_with_country_code(country_code, phone_number)
        PhoneNumberFormatter.new(phone_number: phone_number, iso_country_code: country_code).format
      end
    end
  end
end
