# frozen_string_literal: true

require "spec_helper"

describe "Voting booth flow", type: :system do
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:organization) { component.organization }

  let(:budget) { create(:budget, component: component, total_budget: 100_000) }
  let(:projects_count) { 5 }
  let(:projects) { create_list(:project, projects_count, budget: budget, budget_amount: 25_000) }

  context "when voting is open" do
    let(:component) { create(:budgets_component) }

    before do
      sign_in user
      switch_to_host(organization.host)
      visit decidim_budgets.budget_projects_path(budget)
      click_button "Start voting"
    end

    it_behaves_like "paginated projects" do
      let(:current_budget) { budget }
    end

    it_behaves_like "filtering projects" do
      let!(:current_projects) { projects }
      let(:current_component) { component }
    end

    context "with budget summary" do
      let(:projects_count) { 5 }
      let!(:currnent_projects) { projects }

      before do
        component.update!(settings: { projects_per_page: 3 })
        click_button "Start voting"
      end

      it_behaves_like "budget summary"
      it_behaves_like "cancel voting", "Start voting" do
        let(:current_budget) { budget }
      end
      context "when there is an order" do
        before do
          click_button "Add to your vote", match: :first
          click_button "I understand how to vote"
        end

        it_behaves_like "cancel voting", "FINISH VOTING" do
          let(:current_budget) { budget }
        end
      end
    end

    context "when ordering" do
      let!(:project1) { create(:project, budget: budget, budget_amount: 25_000) }
      let!(:project2) { create(:project, budget: budget, budget_amount: 50_000) }

      context "with highest cost" do
        it_behaves_like "ordering projects by selected option", "Highest cost" do
          let(:first_project) { project2 }
          let(:last_project) { project1 }
        end
      end

      context "with lowest cost" do
        it_behaves_like "ordering projects by selected option", "Lowest cost" do
          let(:first_project) { project1 }
          let(:last_project) { project2 }
        end
      end
    end

    context "with pagination" do
      let!(:currnent_projects) { projects }

      before do
        component.update!(settings: { projects_per_page: 5 })
        click_button "Start voting"
      end

      it_behaves_like "add/remove projects from booth", projects_count: 5

      it "renders the voting booth" do
        expect(page).to have_content "Cancel voting"
        expect(page).to have_content "You decide the budget"
        expect(page).to have_button("I am ready", disabled: true)
        expect(page.find("strong#order-total-budget").text).to eq("€0")
      end

      context "when in paginated page" do
        before do
          component.update!(settings: { projects_per_page: 3 })
          visit decidim_budgets.budget_voting_index_path(budget)
          click_link "2"
        end

        it_behaves_like "add/remove projects from booth", projects_count: 2
      end
    end

    context "when exceeding budget" do
      let(:projects_count) { 2 }
      let!(:currnent_projects) { projects }

      before do
        budget.update!(total_budget: 24_999)
        component.update!(settings: { projects_per_page: 1 })
        click_button "Start voting"
      end

      context "when no pagination" do
        it_behaves_like "maximum budget exceed"
      end

      context "with pagination" do
        before do
          find("li.page", text: "2").click
        end

        it_behaves_like "maximum budget exceed"
      end
    end
  end

  context "when voting is disabled" do
    let(:component) { create(:budgets_component, :with_votes_disabled) }

    before do
      sign_in user
      switch_to_host(organization.host)
      visit decidim_budgets.budget_projects_path(budget)
    end

    it "disables the voting button" do
      expect(page).to have_button("Start voting", disabled: true)
    end
  end

  context "when voting is finished" do
    let(:component) { create(:budgets_component, :with_voting_finished) }

    before do
      sign_in user
      switch_to_host(organization.host)
      visit decidim_budgets.budget_projects_path(budget)
    end

    it "shows the selecte projects" do
      budget_title = budget.title["en"]
      expect(page).not_to have_content("Start voting")
      expect(page).to have_content("Projects for #{budget_title}")
      expect(page.check("Selected")).to be_present
      expect(page.check("Not selected")).to be_present
    end
  end

  context "when voting in one budget enabled" do
    let(:component) { create(:budgets_component) }
    let(:another_budget) { create(:budget, component: component, total_budget: 100_000) }
    let!(:another_budget_projects) { create_list(:project, 3, budget: another_budget, budget_amount: 25_000) }
    let!(:order) do
      order = create(:order,
                     user: user,
                     budget: budget)
      order.projects << projects[0..2]
      order.checked_out_at = Time.current
      order.save!
    end

    before do
      component.update!(settings: { workflow: "one" })
      sign_in user
      switch_to_host(organization.host)
      visit decidim_budgets.budget_projects_path(another_budget)
      click_button "Start voting"
    end

    it "does not let the user to vote" do
      expect(page).to have_current_path decidim_budgets.budget_projects_path(another_budget)
      within_flash_messages do
        expect(page).to have_content("You don't have permission to perform this action.")
      end
      expect(page).to have_content "You have active votes in #{budget.title["en"]}. To vote on this budget you must delete your vote and start over."
    end
  end

  private

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end

  def visit_budget(budget)
    page.visit decidim_budgets.budget_projects_path(budget)
  end
end
