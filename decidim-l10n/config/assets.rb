# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs", prepend: true)

Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/l10n/l10n")
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/l10n/l10n", group: :admin)
