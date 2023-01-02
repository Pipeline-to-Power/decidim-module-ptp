# frozen_string_literal: true

module Decidim
  module Smsauth
    module AccountFormExtensions
      extend ActiveSupport::Concern

      included do
        attribute :phone_number, String
        attribute :phone_country, String

        def mask_number
          return if phone_number.blank? || phone_country.blank?

          formatted = phone_instance.format

          "#{phone_instance.phone_country_code}*****#{formatted[-3..-1]}"
        end

        private

        def phone_instance
          return unless phone_number.present? && phone_country.present?

          Decidim::Smsauth::PhoneNumberFormatter.new(phone_number: phone_number, iso_country_code: phone_country)
        end
      end
    end
  end
end
