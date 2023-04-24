# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/ptp/version"

Gem::Specification.new do |s|
  s.version = Decidim::Ptp.version
  s.authors = ["Sina Eftekhar"]
  s.email = ["sina.eftekhar@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/Pipeline-to-Power/decidim-module-ptp"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-ptp"
  s.summary = "PTP module collection for Decidim"
  s.description = "PTP module collection for Decidim."

  s.files = Dir["{lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Ptp.decidim_version

  s.add_dependency "decidim-budgets_booth", Decidim::Ptp.version
  s.add_dependency "decidim-l10n", Decidim::Ptp.version
  s.add_dependency "decidim-smsauth", Decidim::Ptp.version
  s.add_dependency "decidim-sms-twilio", Decidim::Ptp.version
  s.metadata["rubygems_mfa_required"] = "true"
end
