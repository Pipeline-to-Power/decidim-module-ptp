# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join("..", "spec", "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"
require "decidim/smsauth/test/spec_helper"

RSpec.configure do |config|
  config.before do
    # Re-define the password validators due to a bug in the "email included"
    # check which does not work well for domains such as "1.lvh.me" that we are
    # using during tests.
    PasswordValidator.send(:remove_const, :VALIDATION_METHODS)
    PasswordValidator.const_set(
      :VALIDATION_METHODS,
      [
        :password_too_short?,
        :password_too_long?,
        :not_enough_unique_characters?,
        :name_included_in_password?,
        :nickname_included_in_password?,
        # :email_included_in_password?,
        :domain_included_in_password?,
        :password_too_common?,
        :blacklisted?
      ].freeze
    )
  end
end
