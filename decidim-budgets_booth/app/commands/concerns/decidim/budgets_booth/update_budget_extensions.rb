# frozen_string_literal: true

require "spec_helper"

module Decidim
  module BudgetsBooth
    module UpdateBudgetExtensions
      extend ActiveSupport::Concern

      included do
        private

        def update_budget!
          attributes = {
            scope: form.scope,
            title: form.title,
            weight: form.weight,
            description: form.description,
            total_budget: form.total_budget
          }.merge(
            form.main_image&.attached? ? form.main_image.attachment_attributes : {}
          )

          Decidim.traceability.update!(
            budget,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
