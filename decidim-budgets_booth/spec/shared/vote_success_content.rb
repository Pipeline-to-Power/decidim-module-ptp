# frozen_string_literal: true

shared_examples "vote success content" do
  before do
    first_budget.update!(total_budget: 26_000)
  end

  context "when vote_success_content is not set" do
    before do
      visit current_path
      click_button("Add to your vote", match: :first)
      click_button "Vote"
      click_button "Confirm"
    end

    it "does not show the success message by default" do
      expect(page).to have_no_selector("#thanks-message")
      expect(page).to have_current_path(decidim_budgets.budgets_path)
    end
  end

  context "when vote success is set" do
    before do
      component.update!(settings: { workflow: "zip_code", vote_success_content: { en: "<p>Some dummy text</p>" } })
      visit current_path
      click_button("Add to your vote", match: :first)
      click_button "Vote"
      click_button "Confirm"
    end

    it "shows the success message set" do
      expect(page).to have_selector("#thanks-message")
      within "#thanks-message" do
        expect(page).to have_content("Thank you for voting!")
        expect(page).to have_selector("p", text: "Some dummy text")
      end
      expect(page).to have_current_path(decidim_budgets.budgets_path)
    end
  end
end
