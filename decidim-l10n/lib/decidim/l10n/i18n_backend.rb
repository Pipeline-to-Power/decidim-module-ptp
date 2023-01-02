# frozen_string_literal: true

module Decidim
  module L10n
    # A simple i18n backend implementation to override the locale data with the
    # region specific locales.
    class I18nBackend < I18n::Backend::Simple
      attr_reader :region

      def region=(reg)
        if reg
          reg = reg.to_sym
          return unless available_regions.include?(reg)
        end

        @region = reg
      end

      def available_regions
        init_translations unless initialized?
        translations.keys
      end

      # It does not really matter what this returns because the
      # store_translations method is overridden.
      def available_locales
        [I18n.locale || :en]
      end

      # Based on the original implementation without checking that the locale is
      # in the available locales in case the available locales.
      def store_translations(locale, data, options = I18n::EMPTY_HASH)
        locale = locale.to_sym
        translations[locale] ||= Concurrent::Hash.new
        data = I18n::Utils.deep_symbolize_keys(data) unless options.fetch(:skip_symbolize_keys, false)
        I18n::Utils.deep_merge!(translations[locale], data)
      end

      # Override the translate method to always pass the correct region locale
      # instead of the translations locale.
      def translate(locale, key, options = I18n::EMPTY_HASH)
        super(region.presence || locale, key, options)
      end

      protected

      def init_translations
        load_translations(*data_files)
        @initialized = true
      end

      # Fetches all the files in all data_dirs and returns the existing files
      # from each folder.
      #
      # @return [Array<Pathname>] An array of existing regions configuration
      #   file paths.
      def data_files
        data_dirs.map do |dir|
          Dir.entries(dir).map do |entry|
            path = File.join(dir, entry)
            File.file?(path) ? path : nil
          end.compact
        end.flatten
      end

      # Fetches all the i18n railtie load paths and replaces the "locales"
      # folders to "regions". Also, adds the application's "config/regions"
      # folder in front of the list for potential overrides.
      #
      # Returns only the folders that exist
      #
      # @return [Array<Pathname>] An array of existing regions configuration
      #   directories.
      def data_dirs
        @data_dirs ||= begin
          paths = [Rails.root.join("config/regions")]
          Rails.application.config.i18n.railties_load_path.map do |railtie_paths|
            paths += railtie_paths.to_a.map do |path|
              File.expand_path("../regions", path)
            end
          end
          paths.map { |path| File.directory?(path) ? path : nil }.compact
        end
      end
    end
  end
end
