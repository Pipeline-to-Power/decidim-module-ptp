# frozen_string_literal: true

shared_examples "ordering projects by selected option" do |selected_option|
  before do
    within ".order-by" do
      expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random order")
      page.find("a", text: "Random order").click
      click_link(selected_option)
    end
  end

  it "lists the projects ordered by selected option" do
    within "#projects li.is-dropdown-submenu-parent a" do
      expect(page).to have_no_content("Random order", wait: 20)
      expect(page).to have_content(selected_option)
    end

    expect(page).to have_selector("#projects .budget-list .budget-list__item:first-child", text: translated(first_project.title))
    expect(page).to have_selector("#projects .budget-list .budget-list__item:last-child", text: translated(last_project.title))
  end
end
