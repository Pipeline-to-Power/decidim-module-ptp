# frozen_string_literal: true

shared_examples "non-voting view" do
  include Decidim::Budgets::ProjectsHelper
  let(:projects_title) { projects.map { |p| p.title["en"] } }
  let(:projects_budgets) { ["€25,000", "€50,000"] }
  it "changes the views in the index page" do
    expect(page).to have_content "Welcome to the vote!"
    expect(page).to have_content "START VOTING"
    within ".budget-list__text.card__text.margin-bottom-0", match: :first do
      link_text = page.find("a", match: :first).text
      expect(projects_title).to include(link_text)
    end
    within ".budget-list__data", match: :first do
      project_budget = page.find("span.budget-list__data__number").text
      expect(projects_budgets).to include(project_budget)
    end
    expect(page).to have_no_content("Add to your vote")
    within ".budget-list__text.card__text.margin-bottom-0", match: :first do
      click_link "Read more"
    end
    expect(page).to have_content("Want to vote this project?")
    expect(page).to have_content("Start voting")
    expect(projects_budgets).to include(find(".definition-data__number").text)
    expect(page).to have_content("View all projects")
    click_link "View all projects"
    expect(page).to have_css(".budget-list__item", count: projects.count)
  end
end
