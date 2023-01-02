# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/budgets_booth/version"

Gem::Specification.new do |s|
  s.version = Decidim::BudgetsBooth.version
  s.authors = ["Sina Eftekhar"]
  s.email = ["sina.eftekhar@mainiotech.fi"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-ptp-budgets"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-budgets_booth"
  s.summary = "A Decidim budgets module extension to implement a voting booth"
  s.description = "Improvements to the budgets module based on the customer requirements."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-budgets", Decidim::BudgetsBooth.decidim_version
  s.add_dependency "decidim-core", Decidim::BudgetsBooth.decidim_version
  s.metadata["rubygems_mfa_required"] = "true"
end
