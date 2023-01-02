# frozen_string_literal: true

module Decidim
  module L10n
    module ParticipatoryProcessHelperExtensions
      extend ActiveSupport::Concern

      included do
        def step_dates(participatory_process_step)
          dates = [participatory_process_step.start_date, participatory_process_step.end_date]
          dates.map { |date| date ? localize(date.to_date, format: :decidim_short) : "?" }.join(" - ")
        end
      end
    end
  end
end
