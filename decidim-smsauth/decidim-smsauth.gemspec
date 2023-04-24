# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/smsauth/version"

Gem::Specification.new do |s|
  s.version = Decidim::Smsauth.version
  s.authors = ["Sina Eftekhar"]
  s.email = ["sina.eftekhar@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/Pipeline-to-Power/decidim-module-ptp"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-smsauth"
  s.summary = "A decidim smsauth module"
  s.description = "SMS based authentication implementation."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "countries", "~> 5.1", ">= 5.1.2"
  s.add_dependency "decidim-core", Decidim::Smsauth.decidim_version
  s.metadata["rubygems_mfa_required"] = "true"
end
