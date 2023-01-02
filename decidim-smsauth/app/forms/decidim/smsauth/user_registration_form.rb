# frozen_string_literal:  true

module Decidim
  module Smsauth
    class UserRegistrationForm < Decidim::Form
      include ::Decidim::FormFactory

      attribute :name, String
      attribute :email, String
      attribute :tos_agreement, Boolean
      attribute :phone_number, String
      attribute :phone_country, String
      attribute :newsletter, Boolean
      attribute :current_locale, String
      attribute :organization, Decidim::Organization

      mimic :sms_registration

      validates :tos_agreement, allow_nil: false, acceptance: true
      validates :name, presence: true
      validates :organization, presence: true
      validates :phone_number, presence: true
      validates :phone_country, presence: true
      validate :verify_email_uniqueness, if: ->(form) { form.email.present? }

      def newsletter_at
        return nil unless newsletter?

        Time.current
      end

      def verify_email_uniqueness
        return true if Decidim::User.where(
          organization: organization,
          email: email
        ).empty?

        errors.add :email, :taken
        false
      end
    end
  end
end
