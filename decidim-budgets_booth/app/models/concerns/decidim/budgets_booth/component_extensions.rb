# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module BudgetsBooth
    module ComponentExtensions
      extend ActiveSupport::Concern

      included do
        has_many :budgets_user_data, foreign_key: "decidim_component_id", class_name: "Decidim::Budgets::UserData", dependent: :destroy
      end
    end
  end
end
