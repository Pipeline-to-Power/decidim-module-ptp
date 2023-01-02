# frozen_string_literal: true

require "spec_helper"

describe "Explore initiatives", type: :system do
  let(:organization) { create(:organization) }
  let(:state) { :published }
  let(:initiative) { create(:initiative, organization: organization, state: state, published_at: Time.zone.local(2017, 12, 30, 15, 0, 0)) }

  before do
    switch_to_host(organization.host)
  end

  describe "initiative page" do
    before do
      visit decidim_initiatives.initiative_path(initiative)
    end

    it "shows the details of the given initiative" do
      within(".initiative-authors .publish-date") do
        expect(page).to have_content("12/30/2017")
      end
    end
  end
end
