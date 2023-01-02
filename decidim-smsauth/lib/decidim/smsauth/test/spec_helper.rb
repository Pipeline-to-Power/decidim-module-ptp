# frozen_string_literal: true

module Decidim
  module Smsauth
    module SystemTestHelpers
      def visit_smsauth
        visit decidim_smsauth.users_auth_sms_path
      end

      def visit_verification
        visit decidim_smsauth.users_auth_sms_verification_path
      end
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::Smsauth::SystemTestHelpers, type: :system
end
