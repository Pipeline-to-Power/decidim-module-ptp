# frozen_string_literal: true

require "spec_helper"

describe "Explore meetings", :slow, type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:start_time) { Time.zone.local(2017, 1, 13, 8, 0, 0) }
  let(:end_time) { Time.zone.local(2017, 12, 20, 15, 0, 0) }
  let!(:meeting) { create(:meeting, :not_official, :published, component: component, start_time: start_time, end_time: end_time) }

  # before do
  #   # Required for the link to be pointing to the correct URL with the server
  #   # port since the server port is not defined for the test environment.
  #   # allow(ActionMailer::Base).to receive(:default_url_options).and_return(port: Capybara.server_port)
  #   # component_scope = create :scope, parent: participatory_process.scope
  #   # component_settings = component["settings"]["global"].merge!(scopes_enabled: true, scope_id: component_scope.id)
  #   # component.update!(settings: component_settings)
  # end

  before do
    component.update!(settings: { maps_enabled: false })
  end

  describe "index" do
    before do
      visit_component
    end

    it "shows the meeting date correctly on the card" do
      within("#meeting_#{meeting.id} .card .card__icondata .card-data__item--multiple") do
        expect(page).to have_content("JANUARY 13, 2017 08:00 AM")
        expect(page).to have_content("DECEMBER 20, 2017 03:00 PM")
      end
    end
  end

  describe "show" do
    before do
      visit resource_locator(meeting).path
    end

    it "shows all meeting info" do
      within(".section.view-side") do
        expect(page).to have_css(".extra__date", text: "13")
        expect(page).to have_css(".extra__date .extra__month", text: "January 2017")
        expect(page).to have_css(".extra__time", text: "08:00 AM")
        expect(page).to have_css(".extra__date", text: "20")
        expect(page).to have_css(".extra__date .extra__month", text: "December 2017")
        expect(page).to have_css(".extra__time", text: "03:00 PM")
      end
    end
  end
end
