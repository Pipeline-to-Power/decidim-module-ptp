# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/l10n/version"

Gem::Specification.new do |s|
  s.version = Decidim::L10n.version
  s.authors = ["Sina Eftekhar"]
  s.email = ["sina.eftekhar@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/Pipeline-to-Power/decidim-module-ptp"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-l10n"
  s.summary = "A decidim l10n module"
  s.description = "Localization improvements for the United States."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::L10n.decidim_version
  s.metadata["rubygems_mfa_required"] = "true"
end
