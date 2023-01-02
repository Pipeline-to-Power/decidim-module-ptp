# frozen_string_literal: true

RSpec.shared_context "with single budget" do
  let(:budget) { create(:budget, component: component, total_budget: 100_000) }
end

RSpec.shared_context "with multiple budgets" do
  include_context "with single budget"
  let(:another_budget) { create(:budget, component: component, total_budget: 150_000) }
end

RSpec.shared_context "with single permission" do
  let(:available_authorizations) { %w(dummy_authorization_handler another_dumy_authorization_handler) }
  let(:permissions) do
    {
      vote: {
        authorization_handlers: {
          "dummy_authorization_handler" => {}
        }
      }
    }
  end
  before do
    component.organization.update!(available_authorizations: available_authorizations)
    component.update!(permissions: permissions)
  end
end
