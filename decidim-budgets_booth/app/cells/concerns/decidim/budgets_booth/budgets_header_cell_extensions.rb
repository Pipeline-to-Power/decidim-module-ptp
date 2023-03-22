# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetsHeaderCellExtensions
      extend ActiveSupport::Concern
      included do
        delegate :voting_open?, :voting_finished?, to: :controller
      end
    end
  end
end
