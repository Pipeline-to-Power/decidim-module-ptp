# frozen_string_literal: true

module Decidim
  module Budgets
    class UserDataForm < Decidim::Form
      attribute :metadata, type: :string
      attribute :affirm_statements_are_correct, type: :boolean
      attribute :user, type: :string
      attribute :component, type: :string

      validates :metadata, presence: true
      validates :affirm_statements_are_correct, acceptance: true
      validates :user, presence: true
      validates :component, presence: true
    end
  end
end
