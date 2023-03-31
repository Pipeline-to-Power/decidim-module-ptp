# frozen_string_literal: true

RSpec.shared_context "with scopes" do
  let!(:parent_scopes) { create_list(:scope, 2, organization: organization) }
  let!(:subscopes) { create_list(:scope, 2, parent: parent_scopes.second) }
  let!(:first_postals) { create_list(:scope, 5, parent: parent_scopes.first) }
  let!(:second_postals) { create_list(:scope, 7, parent: subscopes[0]) }
  let!(:third_postals) { create_list(:scope, 8, parent: subscopes[1]) }
  before do
    first_postals.each_with_index do |postal, i|
      postal.update(code: "#{postal.code}_#{i + 1000}")
    end
    second_postals.each_with_index do |postal, i|
      postal.update(code: "#{postal.code}_#{i + 1004}")
    end
    third_postals.each_with_index do |postal, i|
      postal.update(code: "#{postal.code}_#{i + 1010}")
    end
  end
end

RSpec.shared_context "with user_data" do
  let!(:user_data) { create(:user_data, component: component, user: user) }
end
