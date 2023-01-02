# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/sms/twilio/version"

Gem::Specification.new do |s|
  s.version = Decidim::Sms::Twilio.version
  s.authors = ["Sina Eftekhar"]
  s.email = ["sina.eftekhar@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-sms-twilio"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-sms-twilio"
  s.summary = "A decidim sms-twilio module"
  s.description = "Twilio SMS provider integration."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Sms::Twilio.decidim_version
  s.add_dependency "twilio-ruby", "~> 5.72.0"
  s.metadata["rubygems_mfa_required"] = "true"
end
