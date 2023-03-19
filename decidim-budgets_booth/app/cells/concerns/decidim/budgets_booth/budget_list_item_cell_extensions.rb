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
      end
    end
  end
end
