# frozen_string_literal: true

module Decidim
  module Smsauth
    class VerificationCodeForm < Form
      mimic :sms_verification

      attribute :phone_number, Integer
      attribute :phone_country, String
      attribute :verification, String

      validates :verification, presence: true
    end
  end
end
