# frozen_string_literal: true

module Decidim
  module Smsauth
    class RegisterByPhone < Rectify::Command
      include Decidim::Sms::Twilio::TokenGenerator

      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) unless form.valid?

        user = create_user!
        broadcast(:ok, user)
      rescue ActiveRecord::RecordInvalid => e
        broadcast(:error, e.record)
      end

      private

      attr_reader :form

      def create_user!
        generated_password = SecureRandom.hex
        Decidim::User.create! do |record|
          record.name = form.name
          record.nickname = UserBaseEntity.nicknamize(form.name)
          record.email = form.email.presence || generate_email(form.phone_country, form.phone_number)
          record.password = generated_password
          record.password_confirmation = generated_password

          record.skip_confirmation! if form.email.blank?

          record.phone_number = form.phone_number
          record.phone_country = form.phone_country
          record.tos_agreement = "1"
          record.organization = form.organization
          record.newsletter_notifications_at = form.newsletter_at
          record.accepted_tos_version = form.organization.tos_version
          record.locale = form.current_locale
        end
      end

      def generate_email(country, phone)
        EmailGenerator.new(form.organization, country, phone).generate
      end
    end
  end
end
