# frozen_string_literal: true

shared_examples "add/remove projects from booth" do |projects_count:|
  it "adds and removes projects" do
    expect(page).to have_button("Add to your vote", count: projects_count)
    click_button("Add to your vote", match: :first)
    expect(page).to have_content("Your vote has not been cast.")
    click_button "I understand how to vote"
    expect(page).to have_button("Add to your vote", count: projects_count - 1)
    expect(page).to have_button("Remove from vote", count: 1)
    expect(page).to have_css("svg.icon--actions.icon.card--list__icon.card--list__check", count: 1)

    within page.all(".budget-list .budget-list__item")[0] do
      header = page.all("button")[0].text
      click_button "Read more"
      expect(page).to have_content(header)
      expect(page).to have_button("Remove from vote")
    end
    within ".reveal-overlay" do
      click_button "Remove from vote"
      expect(page).to have_button("Add to your vote", count: 1)
    end
  end
end
