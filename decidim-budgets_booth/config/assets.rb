# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs", prepend: true)
Decidim::Webpacker.register_entrypoints(
  decidim_budgets_booth_voting: "#{base_path}/app/packs/entrypoints/decidim_budgets_booth_voting.js",
  decidim_budgets_booth_zip_code: "#{base_path}/app/packs/entrypoints/decidim_budgets_booth_zip_code.js",
  decidim_budgets_booth_budgets: "#{base_path}/app/packs/entrypoints/decidim_budgets_booth_budgets.js",
  decidim_handle_voting_complete: "#{base_path}/app/packs/entrypoints/decidim_handle_voting_complete.js"
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/budgets_booth/budgets_booth")
