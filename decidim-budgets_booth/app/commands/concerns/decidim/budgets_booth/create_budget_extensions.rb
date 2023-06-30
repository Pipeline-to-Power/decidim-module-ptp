# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module CreateBudgetExtensions
      extend ActiveSupport::Concern

      included do
        private

        def create_budget!
          attributes = {
            component: form.current_component,
            scope: form.scope,
            title: form.title,
            weight: form.weight,
            description: form.description,
            total_budget: form.total_budget,
            main_image: form.main_image
          }
          @budget = Decidim.traceability.create!(
            ::Decidim::Budgets::Budget,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
