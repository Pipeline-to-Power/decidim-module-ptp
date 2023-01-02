# frozen_string_literal: true

module Decidim
  module L10n
    module DebateMCellExtensions
      extend ActiveSupport::Concern

      included do
        def formatted_start_time
          l(model.start_time, format: :time_of_day)
        end

        def formatted_end_time
          l(model.end_time, format: :time_of_day)
        end
      end
    end
  end
end
