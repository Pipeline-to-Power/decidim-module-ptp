# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module BudgetsBooth
    module UserExtensions
      extend ActiveSupport::Concern

      included do
        has_many :budgets_user_data, foreign_key: "decidim_user_id", class_name: "::Decidim::Budgets::UserData", dependent: :destroy
      end
    end
  end
end
