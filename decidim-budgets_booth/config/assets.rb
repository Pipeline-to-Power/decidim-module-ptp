# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs", prepend: true)
Decidim::Webpacker.register_entrypoints(
  decidim_budgets_booth_voting: "#{base_path}/app/packs/entrypoints/decidim_budgets_booth_voting.js",
  decidim_zip_code: "#{base_path}/app/packs/entrypoints/decidim_zip_code.js"
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/budgets_booth/budgets_booth")
