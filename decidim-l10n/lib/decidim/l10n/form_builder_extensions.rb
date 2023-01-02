# frozen_string_literal: true

module Decidim
  module L10n
    module FormBuilderExtensions
      extend ActiveSupport::Concern

      included do
        alias_method :datetime_field_core, :datetime_field unless method_defined?(:datetime_field_core)

        def datetime_field(attribute, options = {})
          # In order to avoid overriding the whole original method, we pass the
          # region to the view through a global JS variable.
          unless @template.snippets.any?(:decidim_l10n_picker)
            @template.snippets.add(
              :decidim_l10n_picker,
              %(<script>var I18N_CLOCK_FORMAT = "#{I18n.t("time.clock_format", default: 24)}";</script>)
            )
            @template.snippets.add(:head, @template.snippets.for(:decidim_l10n_picker))
          end

          # Force the datetime fields to have autocomplete off by default
          options[:autocomplete] = "off" unless options.has_key?(:autocomplete) || options.has_key?("autocomplete")

          datetime_field_core(attribute, options)
        end

        private

        def ruby_format_to_datepicker(ruby_date_format)
          ruby_date_format
            .gsub("%d", "d")
            .gsub("%m", "m")
            .gsub("%Y", "Y")
            .gsub("%H", "H")
            .gsub("%I", "h")
            .gsub("%M", "i")
            .gsub("%p", "K")
        end
      end
    end
  end
end
