# frozen_string_literal: true

shared_examples "confirm budget summary info" do |casted_vote|
  it "renders the info" do
    within ".budget-summary__total" do
      expect(page).to have_content("TOTAL BUDGET: €100,000")
    end
    expect(page).to have_content("ASSIGNED: €25,000")
    within "ul.budget-summary__selected-list" do
      expect(page).to have_content("#{voted_projects.first.title["en"]} €25,000")
    end
    if casted_vote
      expect(page).to have_content("Back")
      expect(page).to have_content("Review your vote")
      expect(page).to have_content "THESE ARE THE PROJECTS YOU VOTED FOR:"
      expect(page).to have_content("If you changed your mind, you can cancel your vote and start over.")
    else
      expect(page).to have_content "THESE ARE THE PROJECTS YOU PICKED:"
      expect(page).to have_css("a", text: "I want to change my vote", count: 2)
    end
  end
end
