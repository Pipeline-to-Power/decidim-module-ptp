# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Explore participatory processes", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_process) do
    create(
      :participatory_process,
      :active,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end

  before do
    switch_to_host(organization.host)
  end

  describe "show" do
    context "with accountability results" do
      let(:component) { create(:accountability_component, participatory_space: participatory_process) }
      let!(:record) { create(:result, component: component, start_date: Date.new(2017, 7, 12), end_date: Date.new(2017, 9, 30)) }

      it "displays the dates correctly" do
        visit decidim_participatory_processes.participatory_process_path(participatory_process)

        within(".columns.accountability .card .card--meta") do
          expect(page).to have_content("Start date Jul 12")
          expect(page).to have_content("End date Sep 30")
        end
      end
    end

    context "with meetings" do
      let(:component) { create(:meeting_component, participatory_space: participatory_process) }
      let(:start_time) { Time.zone.local(2017, 1, 13, 8, 0, 0) }
      let(:end_time) { Time.zone.local(2017, 12, 20, 15, 0, 0) }
      let!(:record) { create(:meeting, :not_official, :published, component: component, start_time: start_time, end_time: end_time) }

      it "displays the dates correctly" do
        visit decidim_participatory_processes.participatory_process_path(participatory_process)

        within(".section.past_meetings .card .text-small") do
          # Does not really indicate both dates but this is how the meetings
          # component is set to work by default.
          expect(page).to have_content("January 13, 2017 - 08:00 AM-03:00 PM")
        end
      end
    end

    context "with proposals" do
      let(:component) { create(:proposal_component, participatory_space: participatory_process) }
      let!(:record) { create(:proposal, published_at: Time.zone.local(2017, 1, 13, 8, 0, 0), component: component) }

      it "displays the dates correctly" do
        visit decidim_participatory_processes.participatory_process_path(participatory_process)

        within("#proposal_#{record.id} .card .card__status .creation_date_status") do
          expect(page).to have_content("CREATED AT\n\n01/13/2017")
        end
      end
    end
  end
end
