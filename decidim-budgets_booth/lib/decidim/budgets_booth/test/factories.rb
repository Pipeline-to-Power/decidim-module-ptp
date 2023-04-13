# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :user_data, class: "Decidim::Budgets::UserData" do
    association :component, factory: :budgets_component
    association :user, factory: :user
    affirm_statements_are_correct { true }
    metadata do
      {
        zip_code: ""
      }
    end

    before(:create) do |user_data, evaluator|
      user_data.metadata = evaluator.metadata if evaluator.metadata.present?
    end
  end
end
