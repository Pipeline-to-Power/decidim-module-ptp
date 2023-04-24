# frozen_string_literal: true

module Decidim
  module Budgets
    class UserDataForm < Decidim::Form
      attribute :zip_code, String
      attribute :affirm_statements_are_correct, Boolean
      attribute :user, String
      attribute :component, String

      validates :zip_code, presence: true
      validates :affirm_statements_are_correct, acceptance: true
      validates :user, presence: true
      validates :component, presence: true
    end
  end
end
