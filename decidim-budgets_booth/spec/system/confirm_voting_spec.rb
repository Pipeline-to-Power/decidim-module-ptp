# frozen_string_literal: true

require "spec_helper"

describe "Confirm voting", type: :system do
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:organization) { component.organization }
  let(:settings) { { vote_threshold_percent: 20 } }
  let(:component) { create(:budgets_component, settings: settings) }

  let(:budget) { create(:budget, component: component, total_budget: 100_000) }
  let(:projects_count) { 2 }

  before do
    sign_in user
    switch_to_host(organization.host)
  end

  describe "confirmation" do
    let!(:projects) { create_list(:project, projects_count, budget: budget, budget_amount: 25_000) }

    before do
      visit decidim_budgets.budget_projects_path(budget)
      click_button "Start voting"
      click_button "Add to your vote", match: :first
      click_button "I understand how to vote"
      page.find("button.button.small.button--sc.margin-0").click
    end

    it_behaves_like "confirm budget summary info", false

    context "when changing votes" do
      before do
        page.find("a.link").click
      end

      it "renders the voting page" do
        expect(page).to have_current_path decidim_budgets.budget_voting_index_path(budget)
        expect(page).to have_content("1 project selected")
        expect(voted_projects.count).to eq(1)
      end
    end

    describe "confirm vote" do
      before do
        click_button "Cast your vote"
      end

      it "cast the votes" do
        within ".reveal" do
          expect(page).to have_content("Thank you for voting!")
          expect(page).to have_css("svg", count: 1)
          expect(page).to have_content(/Your vote has now been cast./)
          click_button "Continue"
        end
        expect(page).to have_content("Review your vote")
        expect(page).to have_content("Thank you for voting")
        expect(page).to have_css("svg.icon--check.icon", count: 1)
        expect(current_vote.checked_out_at).not_to be_nil
        click_link("Review your vote")
      end
    end

    describe "confirm text" do
      context "when no thanks text is set" do
        before do
          click_button "Cast your vote"
        end

        it "shows the default value" do
          within ".reveal" do
            expect(page).to have_content(/Your vote has now been cast./)
          end
        end
      end

      context "when thanks message is set" do
        let(:settings) { { vote_threshold_percent: 20, thanks_text: { "en" => "Dummy text" } } }

        before do
          visit current_path
          click_button "Cast your vote"
        end

        it "shows thanks text in popup" do
          within ".reveal" do
            expect(page).to have_content("Dummy text")
          end
        end
      end
    end
  end

  describe "review votes" do
    let!(:selected_project) { create(:project, budget: budget, budget_amount: 25_000) }
    let!(:finished_order) do
      order = create(:order, user: user, budget: budget)
      order.projects << selected_project
      order.checked_out_at = Time.current
      order.save!
      order
    end

    before do
      visit decidim_budgets.budget_projects_path(budget)
      click_link("Review your vote")
    end

    it_behaves_like "confirm budget summary info", true
  end

  private

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end

  def visit_budget
    page.visit decidim_budgets.budget_projects_path(budget)
  end

  def current_vote
    Decidim::Budgets::Order.find_by(decidim_user_id: user.id, decidim_budgets_budget_id: budget.id)
  end

  def voted_projects
    current_vote.projects
  end
end
