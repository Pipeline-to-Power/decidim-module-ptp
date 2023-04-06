# frozen_string_literal: true

require "spec_helper"

describe "user data workflow", type: :system do
  include_context "with scoped budgets"
  let(:projects_count) { 4 }
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:organization) { component.organization }
  let(:first_budget) { budgets.first }

  before do
    switch_to_host(organization.host)
  end

  context "when not zip_code workflow" do
    before do
      visit decidim_budgets.new_zip_code_path
    end

    it_behaves_like "ensure zip code workflow"
  end

  context "when not signed in" do
    before do
      component.update(settings: { workflow: "zip_code" })
      visit decidim_budgets.new_zip_code_path
    end

    it_behaves_like "ensure user sign in"
  end

  context "when voted" do
    let!(:order) { create(:order, user: user, budget: first_budget) }

    before do
      component.update(settings: { workflow: "zip_code" })
      order.projects << first_budget.projects.first
      order.projects << first_budget.projects.second
      order.projects << first_budget.projects.third
      order.checked_out_at = Time.current
      order.save!
      sign_in user, scope: :user
      visit decidim_budgets.new_zip_code_path
    end

    it "does not let adding zip code" do
      within_flash_messages do
        expect(page).to have_content("You can not change your zip code after started voting. Delete all of your votes first.")
      end
      expect(page).to have_current_path("/")
    end
  end
end
