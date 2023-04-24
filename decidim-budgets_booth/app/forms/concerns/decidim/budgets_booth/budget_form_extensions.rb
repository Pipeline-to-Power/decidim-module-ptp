# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetFormExtensions
      extend ActiveSupport::Concern

      included do
        attribute :main_image
        validates :main_image, passthru: {
          to: ::Decidim::Budgets::Budget,
          with: {
            component: lambda do |form|
              space = Decidim.participatory_space_manifests.first.model_class_name.constantize.new(
                organization: form.current_organization
              )

              Decidim::Component.new(participatory_space: space)
            end
          }
        }
      end
    end
  end
end
