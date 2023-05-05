# frozen_string_literal: true

shared_examples "budget summary" do
  before do
    click_button "Add to your vote", match: :first
    click_button "I understand how to vote"
  end

  it "updates budget summary" do
    within ".budget-summary__total" do
      expect(page).to have_content("TOTAL BUDGET €100,000")
    end
    expect(page).to have_content("ASSIGNED: €25,000")
    within "#order-selected-projects" do
      expect(page).to have_content "1 project selected"
    end
    within ".progress.budget-progress" do
      expect(page).to have_css(".progress-meter-text.progress-meter-text--right", match: :first, text: "25%")
    end
    within page.all(".budget-list .budget-list__item")[1] do
      click_button "Read more"
    end
    within ".reveal-overlay" do
      click_button "Add to your vote"
    end
    page.find(".close-button").click
    expect(page).to have_content("ASSIGNED: €50,000")
    within "#order-selected-projects" do
      expect(page).to have_content "2 projects selected"
    end
    within ".progress.budget-progress" do
      expect(page).to have_css(".progress-meter-text.progress-meter-text--right", match: :first, text: "50%")
    end
    click_link "2"
    click_button "Add to your vote", match: :first
    expect(page).to have_content("ASSIGNED: €75,000")
    within "#order-selected-projects" do
      expect(page).to have_content "3 projects selected"
    end

    within page.all(".budget-list .budget-list__item")[0] do
      click_button "Read more"
    end
    within ".reveal-overlay" do
      click_button "Remove from vote"
    end
    expect(page).to have_content("ASSIGNED: €50,000")
    within "#order-selected-projects" do
      expect(page).to have_content "2 projects selected"
    end
  end
end
