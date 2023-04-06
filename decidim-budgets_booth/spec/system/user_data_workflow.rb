# frozen_string_literal: true

require "spec_helper"

describe "user data workflow", type: :system do
  include_context "with scoped budgets"
  let(:projects_count) { 1 }
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:organization) { component.organization }
  let(:first_budget) { budgets.first }
  let(:second_budget) { budgets.second }
  let(:active_step_id) { component.participatory_space.active_step.id }

  before do
    switch_to_host(organization.host)
  end

  context "when not zip_code workflow" do
    before do
      visit_budget(first_budget)
    end

end
