# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetListItemCellExtensions
      extend ActiveSupport::Concern
      include BudgetsControllerHelper

      included do
        delegate :voting_open?, :voting_finished?, to: :controller

        def button_text
          t(:vote, scope: i18n_scope)
        end

        def mark_image_as_voted(budget)
          return nil unless voted_this?(budget)

          return nil unless voting_open?

          " voted-budget"
        end

        def generate_projects_link(resource)
          if voting_open?
            budget_voting_index_path(resource)
          else
            budget_path(resource)
          end
        end

        def resource_description(model)
          raw = translated_attribute(model.description)
          return raw if raw.length < 65

          "#{raw[0..65]} ..."
        end

        private

        def scope_manager
          @scope_manager ||= ::Decidim::BudgetsBooth::ScopeManager.new
        end

        def budget_scope_type(budget)
          type = translated_attribute(budget&.scope&.scope_type&.name)
          return if type.blank?

          type.split.last
        end
      end
    end
  end
end
