# frozen_string_literal: true

RSpec.shared_examples "rendering new zip code page" do |zip_code_length|
  it "renders new zip code page correctly" do
    expect(page).to have_current_path(decidim_budgets.new_zip_code_path)
    expect(page).to have_no_selector(".flash")
    expect(page).to have_content("Welcome to the")
    expect(page).to have_content("Please provide your ZIP code to find your Participatory Budgeting ballots.")
    expect(page).to have_css('input[type="text"]', count: zip_code_length)
  end
end
