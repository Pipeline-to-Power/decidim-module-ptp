# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module UpdateBudgetExtensions
      extend ActiveSupport::Concern
      include ::Decidim::AttachmentAttributesMethods

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
            attachment_attributes(:main_image)
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
