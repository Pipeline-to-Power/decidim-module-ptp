# frozen_string_literal: true

require "spec_helper"

describe "Explore results", versioning: true, type: :system do
  include_context "with a component"

  let(:manifest_name) { "accountability" }
  let(:results_count) { 5 }
  let!(:result) { create(:result, component: component, start_date: Date.new(2017, 7, 12), end_date: Date.new(2017, 9, 30)) }
  let!(:timeline_entry) { create(:timeline_entry, result: result, entry_date: Date.new(2017, 8, 20)) }

  before do
    visit path
  end

  describe "index" do
    let(:path) { decidim_participatory_process_accountability.results_path(participatory_process_slug: participatory_process.slug, component_id: component.id) }

    it "shows all results for the given process and category" do
      within("#results") do
        expect(page).to have_content("07/12/2017")
        expect(page).to have_content("09/30/2017")
      end
    end
  end

  describe "show" do
    let(:path) { decidim_participatory_process_accountability.result_path(id: result.id, participatory_process_slug: participatory_process.slug, component_id: component.id) }

    it "displays the dates correctly" do
      within(".result-view") do
        expect(page).to have_content("07/12/2017")
        expect(page).to have_content("09/30/2017")

        within(".timeline") do
          expect(page).to have_content("08/20/2017")
        end
      end
    end
  end
end
