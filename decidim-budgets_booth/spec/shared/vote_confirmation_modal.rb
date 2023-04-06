# frozen_string_literal: true

shared_examples "vote confirmation modal" do
  it "renders the info" do
    within "#budget-confirm" do
      expect(page).to have_content("These are the projects you have chosen to be part of the budget.")
      expect(page).to have_selector("li", text: "€25,000", count: 1)
      expect(page).to have_button("Confirm")
      expect(page).to have_button("Cancel")
      click_button("Cancel")
    end
    expect(page).to have_current_path(decidim_budgets.budget_voting_index_path(first_budget))
  end
end
