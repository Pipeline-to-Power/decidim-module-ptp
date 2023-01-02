# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectVoteButtonCellExtensions
      extend ActiveSupport::Concern

      included do
        def scale_up
          "tiny" unless options[:scale_up]
        end
      end
    end
  end
end
