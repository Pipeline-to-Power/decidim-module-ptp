# frozen_string_literal: true

shared_examples "paginated projects" do
  it "paginates the projects" do
    expect(page).to have_css(".budget-list .budget-list__item", count: 5)
    find("li.page", text: "2").click
    expect(page).to have_css(".budget-list .budget-list__item", count: 5)
  end
end
