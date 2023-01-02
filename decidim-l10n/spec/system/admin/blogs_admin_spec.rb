# frozen_string_literal: true

require "spec_helper"

describe "Admin manages accountability", type: :system do
  let(:manifest_name) { "blogs" }

  let(:post1_date) { Time.zone.local(2017, 1, 13, 8, 0, 0) }
  let(:post2_date) { Time.zone.local(2017, 12, 20, 15, 0, 0) }
  # 0.27: Add published_at
  let!(:post1) { create :post, component: current_component, author: author, title: { en: "Post title 1" }, created_at: post1_date }
  let!(:post2) { create :post, component: current_component, title: { en: "Post title 2" }, created_at: post2_date }
  let(:author) { create :user, organization: organization }

  include_context "when managing a component as a process admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  it "displays the dates correctly" do
    expect(page).to have_content("01/13/2017 08:00 AM")
    expect(page).to have_content("12/20/2017 03:00 PM")
  end
end
