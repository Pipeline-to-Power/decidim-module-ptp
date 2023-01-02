# frozen_string_literal: true

require "decidim/l10n/engine"

module Decidim
  # This namespace holds the logic of the `l10n` module. This module provides
  # localization improvements to Decidim.
  module L10n
    autoload :FormBuilderExtensions, "decidim/l10n/form_builder_extensions"
    autoload :I18nBackend, "decidim/l10n/i18n_backend"

    def self.i18n_backend
      @i18n_backend ||= Decidim::L10n::I18nBackend.new
    end
  end
end
