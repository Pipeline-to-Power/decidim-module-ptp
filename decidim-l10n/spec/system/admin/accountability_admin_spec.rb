# frozen_string_literal: true

require "spec_helper"

describe "Admin manages accountability", type: :system do
  let(:manifest_name) { "accountability" }

  let!(:result) { create :result, component: current_component }
  let!(:child_result) { create :result, component: current_component, parent: result }
  let!(:status) { create :status, key: "ongoing", name: { en: "Ongoing" }, component: current_component }
  let!(:timeline_entry) { create(:timeline_entry, result: result, entry_date: Date.new(2017, 12, 20)) }

  include_context "when managing a component as a process admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "timeline entries" do
    before do
      click_link "Project evolution"
    end

    it "displays the date in correct format" do
      expect(page).to have_content("12/20/2017")
    end
  end
end
