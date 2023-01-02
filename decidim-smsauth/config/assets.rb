# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_smsauth: "#{base_path}/app/packs/entrypoints/decidim_smsauth.js",
  decidim_select_country: "#{base_path}/app/packs/entrypoints/decidim_select_country.js",
  decidim_newsletter_checkbox: "#{base_path}/app/packs/entrypoints/decidim_newsletter_checkbox.js"
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/smsauth/smsauth")
