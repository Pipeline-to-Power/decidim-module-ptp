# frozen_string_literal: true

shared_examples "budget booth layout" do
  it "renders the page correctly" do
    expect(page).to have_content("You are now in the voting booth.")
    expect(page).to have_button("Cancel voting")
    expect(page).to have_content("TOTAL BUDGET €100,000")
    expect(page).to have_content("10 PROJECTS")
    expect(page).to have_selector("button", text: "Read more", count: 5)
    expect(page).to have_selector("button", text: "Add to your vote", count: 5)
  end
end
