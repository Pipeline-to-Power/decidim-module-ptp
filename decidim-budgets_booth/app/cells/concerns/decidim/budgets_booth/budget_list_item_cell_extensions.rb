# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetListItemCellExtensions
      extend ActiveSupport::Concern
      include BudgetsControllerHelper
      include ScopeManager

      included do
        def button_text
          t(:vote, scope: i18n_scope)
        end

        def mark_image_as_voted(budget)
          return nil unless current_workflow.status(budget) == :voted

          "voted-budget"
        end
      end
    end
  end
end
