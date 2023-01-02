# frozen_string_literal: true

module Decidim
  module Smsauth
    class PhoneNumberFormatter
      def initialize(phone_number:, iso_country_code:)
        @phone_number = phone_number
        @iso_country_code = iso_country_code
      end

      def format
        "#{phone_country_code}#{phone_number}"
      end

      def phone_country_code
        "+#{ISO3166::Country.find_country_by_alpha2(iso_country_code).country_code}"
      end

      private

      attr_reader :phone_number, :iso_country_code
    end
  end
end
