# frozen_string_literal: true

RSpec.shared_context "with scopes" do
  let!(:parent_scopes) { create_list(:scope, 2, organization: organization) }
  let!(:subscopes) { create_list(:scope, 2, parent: parent_scopes.second) }
  let!(:first_postals) { create_list(:scope, 5, parent: parent_scopes.first) }
  let!(:second_postals) { create_list(:scope, 7, parent: subscopes[0]) }
  let!(:third_postals) { create_list(:scope, 8, parent: subscopes[1]) }
  before do
    first_postals.each_with_index do |postal, i|
      postal.update(code: "#{postal.code}_#{i + 10_000}")
    end
    second_postals.each_with_index do |postal, i|
      postal.update(code: "#{postal.code}_#{i + 10_004}")
    end
    third_postals.each_with_index do |postal, i|
      postal.update(code: "#{postal.code}_#{i + 10_010}")
    end
  end
end

RSpec.shared_context "with user_data" do
  let!(:user_data) { create(:user_data, component: component, user: user) }
end

RSpec.shared_context "with scoped budgets" do
  include_context "with scopes"
  let(:component) { create(:budgets_component) }
  let(:budgets) { create_list(:budget, 3, component: component, total_budget: 100_000) }
  let!(:first_projects_set) { create_list(:project, projects_count, budget: budgets.first, budget_amount: 25_000) }
  let!(:second_projects_set) { create_list(:project, projects_count, budget: budgets.second, budget_amount: 25_000) }
  let!(:last_projects_set) { create_list(:project, projects_count, budget: budgets.last, budget_amount: 25_000) }

  before do
    # We update the description to be less than the truncation limit. To test the truncation, we update those in tests.
    attach_images(budgets)
    budgets.first.update!(scope: parent_scopes.first, description: { en: "<p>Eius officiis expedita. 55</p>" })
    budgets.second.update!(scope: subscopes.first, description: { en: "<p>Eius officiis expedita. 56</p>" })
    budgets.last.update!(scope: subscopes.last)
  end
end

RSpec.shared_context "with zip_code workflow" do
  let!(:component) do
    create(
      :budgets_component,
      settings: { workflow: "zip_code" }
    )
  end
end

private

def attach_images(budgets)
  city_files = ["city.jpeg", "city2.jpeg", "city3.jpeg"]
  budgets.each_with_index do |budget, ind|
    budget.update(main_image: ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset(city_files[ind])),
      filename: city_files[ind],
      content_type: "image/jpeg"
    ))
  end
end
