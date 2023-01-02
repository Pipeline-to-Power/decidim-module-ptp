# frozen_string_literal: true

shared_examples "paginated projects" do
  before do
    component.update!(settings: { projects_per_page: 2 })
    create_list(:project, 3, budget: current_budget)
    visit current_path
  end

  it "paginates the projects" do
    expect(page).to have_css(".budget-list .budget-list__item", count: 2)
    find("li.page", text: "2").click
    expect(page).to have_css(".budget-list .budget-list__item", count: 1)
  end

  private

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end

  def visit_budget
    page.visit decidim_budgets.budget_projects_path(current_budget)
  end
end
