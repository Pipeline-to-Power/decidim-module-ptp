# frozen_string_literal: true

require "securerandom"

module Decidim
  module Smsauth
    module Verification
      class ConfirmationForm < AuthorizationHandler
        attribute :verification_code, String

        validates :verification_code, presence: true

        def verification_metadata
          { "verification_code" => verification_code }
        end
      end
    end
  end
end
