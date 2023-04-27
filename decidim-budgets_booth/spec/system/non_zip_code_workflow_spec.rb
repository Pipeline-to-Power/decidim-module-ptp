# frozen_string_literal: true

require "spec_helper"

describe "Non zip code workflow", type: :system do
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:organization) { component.organization }
  let(:component) { create(:budgets_component) }

  let(:budget) { create(:budget, component: component, total_budget: 100_000) }
  let!(:project1) { create(:project, budget: budget, budget_amount: 25_000) }
  let!(:project2) { create(:project, budget: budget, budget_amount: 50_000) }

  before do
    switch_to_host(organization.host)
  end

  context "when not voting" do
    before do
      visit decidim_budgets.budgets_path
      click_link "Show", match: :first
    end

    it_behaves_like "non-voting view" do
      let!(:projects) { [project1, project2] }
    end

    it_behaves_like "filtering projects" do
      let!(:projects) { [project1, project2] }
      let(:current_component) { component }
      let(:voting_mode) { false }
    end

    it "explores the budgets" do
      expect(page).to have_content("Welcome to the vote!")
      expect(page).to have_content("Start voting")
      expect(page).not_to have_content("Back to budgets")
    end

    context "when ordering by highest cost" do
      it_behaves_like "ordering projects by selected option", "Highest cost" do
        let(:first_project) { project2 }
        let(:last_project) { project1 }
      end
    end

    context "when ordering by lowest cost" do
      it_behaves_like "ordering projects by selected option", "Lowest cost" do
        let(:first_project) { project1 }
        let(:last_project) { project2 }
      end
    end
  end

  context "when entering voting" do
    context "when use is not signed_in" do
      before do
        visit decidim_budgets.budget_voting_index_path(budget)
      end

      it "sends the user to the sign in page" do
        expect(page).to have_current_path "/users/sign_in"
        within_flash_messages do
          expect(page).to have_content "You need to login first."
        end
      end
    end

    context "when authorized" do
      before do
        sign_in user
        visit decidim_budgets.budget_voting_index_path(budget)
      end

      it "enters the voting booth" do
        expect(page).to have_content("You are now in the voting booth.")
        expect(page).to have_current_path(decidim_budgets.budget_voting_index_path(budget))
      end
    end
  end
end
