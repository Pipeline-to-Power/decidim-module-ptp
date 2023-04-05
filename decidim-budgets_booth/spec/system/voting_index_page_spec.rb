# frozen_string_literal: true

require "spec_helper"

describe "Voting index page", type: :system do
  include_context "with scoped budgets"
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

    it "redirects user to root path" do
      expect(page).to have_current_path "/"
      within_flash_messages do
        expect(page).to have_content "You are not allowed to perform this action."
      end
    end
  end

  context "when not signed in" do
    before do
      component.update(settings: { workflow: "zip_code" }, step_settings: { active_step_id => { votes_enabled: false } })
      visit_budget(first_budget)
    end

    it "redirects user to the login page" do
      expect(page).to have_current_path(decidim.new_user_session_path)
      within_flash_messages do
        expect(page).to have_content "You need to login first."
      end
    end
  end

  context "when no user_data" do
    before do
      component.update(settings: { workflow: "zip_code" }, step_settings: { active_step_id => { votes_enabled: false } })
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it "redirects the user" do
      expect(page).to have_current_path("/")
      within_flash_messages do
        expect(page).to have_content "You are not authorized to perform this action"
      end
    end
  end

  context "when not allowed to vote that budget" do
    let!(:user_data) { create(:user_data, component: component, user: user) }

    before do
      component.update(settings: { workflow: "zip_code" }, step_settings: { active_step_id => { votes_enabled: false } })
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it "redirects the user" do
      expect(page).to have_current_path("/")
      within_flash_messages do
        expect(page).to have_content "You are not authorized to perform this action"
      end
    end
  end

  context "when voted to that budget" do
    let!(:user_data) { create(:user_data, component: component, user: user) }
    let!(:order) { create(:order, :with_projects, user: user, budget: first_budget) }

    before do
      component.update(settings: { workflow: "zip_code" }, step_settings: { active_step_id => { votes_enabled: false } })
      order.update!(checked_out_at: Time.current)
      user_data.update!(metadata: "1004")
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it "redirects the user" do
      expect(page).to have_current_path(decidim_budgets.budgets_path)
      within_flash_messages do
        expect(page).to have_content "You are not allowed to perform this action."
      end
    end
  end

  describe "voting" do
    let!(:user_data) { create(:user_data, component: component, user: user) }

    before do
      component.update(settings: { workflow: "zip_code", projects_per_page: 5 }, step_settings: { active_step_id => { votes_enabled: false } })
      user_data.update!(metadata: "1004")
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it_behaves_like "budget booth layout"
    it_behaves_like "budget summary"
    it_behaves_like "cancel voting"
    it_behaves_like "paginated projects"
    it_behaves_like "add/remove projects from booth", projects_count: 5
    it_behves_like "filtering projects"

    context "when maximum budget exceeds" do
      before do
        first_budget.update!(total_budget: 24_999)
        visit current_path
      end

      it_behaves_like "maximum budget exceed"
    end

    context "when highest cost" do
      before { first_budget.projects.second.update!(budget_amount: 30_000) }

      it_behaves_like "ordering projects by selected option", "Highest cost" do
        let(:first_project) { first_budget.projects.second }
      end
    end

    context "when lowest cost" do
      before { first_budget.projects.second.update!(budget_amount: 20_000) }

      it_behaves_like "ordering projects by selected option", "Lowest cost" do
        let(:first_project) { first_budget.projects.second }
      end
    end
  end

  private

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end

  def budget_path(budget)
    decidim_budgets.budget_path(budget.id)
  end

  def visit_budget(budget)
    visit decidim_budgets.budget_voting_index_path(budget)
  end
end
