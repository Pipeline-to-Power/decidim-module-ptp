# frozen_string_literal: true

require "spec_helper"

describe "Explore blogs", versioning: true, type: :system do
  include_context "with a component"
  let(:manifest_name) { "blogs" }

  let(:post1_date) { Time.zone.local(2017, 1, 13, 8, 0, 0) }
  let(:post2_date) { Time.zone.local(2017, 12, 20, 15, 0, 0) }
  # 0.27: Add published_at
  let!(:post1) { create(:post, component: component, created_at: post1_date) }
  let!(:post2) { create(:post, component: component, created_at: post2_date) }

  let!(:comment1) { create(:comment, commentable: post1) }
  let!(:comment2) { create(:comment, commentable: post2) }

  describe "index" do
    it "shows all posts for the given process" do
      visit_component

      within("#most-commented") do
        expect(page).to have_content("01/13/2017")
        expect(page).to have_content("12/20/2017")
      end
    end
  end
end
