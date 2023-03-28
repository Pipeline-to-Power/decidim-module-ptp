# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :user_data, class: "Decidim::Budgets::UserData" do
    association :component, factory: :budgets_component
    association :user, factory: :user
    affirm_statements_are_correct { true }
    metadata { "" }
  end
end
