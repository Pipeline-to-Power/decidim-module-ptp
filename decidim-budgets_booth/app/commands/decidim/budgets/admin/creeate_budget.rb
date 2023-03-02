# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user creates an Budget
      # from the admin panel.
      class CreateBudget < Decidim::Command
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) if form.invalid?

          create_budget!
          return broadcast(:ok, budget) if budget.persisted?

          form.errors.add(:main_image, budget.errors[:hero_image]) if budget.errors.include? :main_image
          broadcast(:invalid)
        end

        private

        attr_reader :form, :budget

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
            Budget,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
