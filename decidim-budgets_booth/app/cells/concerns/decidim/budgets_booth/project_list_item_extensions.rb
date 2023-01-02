# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # Customizes the project card cell
    module ProjectListItemExtensions
      extend ActiveSupport::Concern

      included do
        def voting?
          options[:voting]
        end

        def resource_text
          raw = translated_attribute(model.description)
          return raw if raw.length < 65

          "#{raw[0..trimmer]} ...<br/>"
        end

        def selected_budget
          return unless can_have_order? && resource_added?

          "hollow"
        end

        private

        def trimmer
          65
        end
      end
    end
  end
end
