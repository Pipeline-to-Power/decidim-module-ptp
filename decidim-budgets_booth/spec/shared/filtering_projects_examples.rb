# frozen_string_literal: true

shared_examples "filtering projects" do
  let!(:project) { projects.first }
  let!(:categories) { create_list(:category, 3, participatory_space: current_component.participatory_space) }
  context "when filtering" do
    it "allows searching by text" do
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
      scope = create(:scope, organization: current_component.organization)
      project.scope = scope
      project.save

      visit_budget

      within ".filters__section.with_any_scope_check_boxes_tree_filter" do
        uncheck "All"
        check translated(scope.name)
      end

      within "#projects" do
        expect(page).to have_css(".budget-list__item", count: 1)
        expect(page).to have_content(translated(project.title))
      end
    end

    it "allows filtering by category" do
      category = categories.first
      project.category = category
      project.save

      visit_budget
      within ".filters__section.with_any_category_check_boxes_tree_filter" do
        uncheck "All"
        check translated(category.name)
      end

      within "#projects" do
        expect(page).to have_css(".budget-list__item", count: 1)
        expect(page).to have_content(translated(project.title))
      end
    end

    it "works with 'back to list' link" do
      category = categories.first
      project.category = category
      project.save

      visit_budget

      within ".filters__section.with_any_category_check_boxes_tree_filter" do
        uncheck "All"
        check translated(category.name)
      end

      within "#projects" do
        expect(page).to have_css(".budget-list__item", count: 1)
        expect(page).to have_content(translated(project.title))
      end

      find("a", text: "Read more", match: :first).click
      click_link "View all projects"

      within "#projects" do
        expect(page).to have_css(".budget-list__item", count: 1)
        expect(page).to have_content(translated(project.title))
      end
    end
  end

  private

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end

  def visit_budget
    page.visit decidim_budgets.budget_projects_path(budget)
  end
end
