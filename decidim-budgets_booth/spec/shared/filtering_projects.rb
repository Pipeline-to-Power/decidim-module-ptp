# frozen_string_literal: true

shared_examples "filtering projects" do
  let!(:categories) { create_list(:category, 3, participatory_space: component.participatory_space) }
  let(:current_projects) { first_budget.projects }
  context "when filtering" do
    it "allows searching by text" do
      project = current_projects.first
      within ".filters__search" do
        fill_in "filter[search_text_cont]", with: translated(project.title)

        find(".button").click
      end

      within "#projects" do
        expect(page).to have_css(".budget-list__item", count: 1)
        expect(page).to have_content(translated(project.title))
      end
    end

    it "allows filtering by scope" do
      project = current_projects.first
      project.scope = first_budget.scope
      project.save
      visit current_path

      within ".filters__section.with_any_scope_check_boxes_tree_filter" do
        uncheck "All"
        check translated(first_budget.scope.name)
      end

      within "#projects" do
        expect(page).to have_css(".budget-list__item", count: 1)
        expect(page).to have_content(translated(project.title))
      end
    end

    it "allows filtering by category" do
      project = current_projects.first
      category = categories.first
      project.category = category
      project.save

      visit current_path
      within ".filters__section.with_any_category_check_boxes_tree_filter" do
        uncheck "All"
        check translated(category.name)
      end

      within "#projects" do
        expect(page).to have_css(".budget-list__item", count: 1)
        expect(page).to have_content(translated(project.title))
      end
    end
  end
end
