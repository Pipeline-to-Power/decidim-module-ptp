# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module ProjectVotedHintCellExtensions
      extend ActiveSupport::Concern

      included do
        def css_class
          # css = ["text-sm", "text-success"]
          css = ["text-success"]
          css << options[:class] if options[:class]
          css << "text-sm" unless options[:class].include?("text-m")
          css.join(" ")
        end
      end
    end
  end
end
