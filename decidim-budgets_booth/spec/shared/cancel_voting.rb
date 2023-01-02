# frozen_string_literal: true

shared_examples "cancel voting" do |action|
  it "cancels voting and returns to normal flow" do
    expect(page).to have_content "Cancel voting"
    click_button "Cancel voting"
    within ".reveal" do
      expect(page).to have_content "Are you sure you don't want to cast your vote?"
      expect(page).to have_css("button.button.expanded", text: "Continue voting")
      expect(page).to have_css("a.button.hollow.expanded", text: "I don't want to vote right now")
      click_button "Continue voting"
    end
    expect(page).to have_current_path(decidim_budgets.budget_voting_index_path(budget))
    click_button "Cancel voting"
    within ".reveal" do
      click_link "I don't want to vote right now"
    end
    expect(page).to have_current_path(decidim_budgets.budget_projects_path(budget))
    expect(page).to have_content(action)
  end

  private

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end

  def visit_budget
    page.visit decidim_budgets.budget_projects_path(current_budget)
  end
end
