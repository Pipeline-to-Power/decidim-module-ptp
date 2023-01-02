# frozen_string_literal: true

module Decidim
  module Smsauth
    # Abstract class from which all models in this engine inherit.
    module SmsConfirmableUser
      extend ActiveSupport::Concern

      included do
        def email
          super || generated_phone_email
        end

        def confirmed?
          super || confirmed_phone?
        end

        def confirmation_period_valid?
          return true if confirmed_phone?

          super
        end
      end

      def confirmed_phone?
        phone_number.present? && phone_country.present?
      end

      private

      def generated_phone_email
        return nil unless confirmed_phone?

        @generated_phone_email ||= EmailGenerator.new(organization, phone_country, phone_number).generate
      end
    end
  end
end
