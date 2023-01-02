# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::DebateMCell, type: :cell do
  controller Decidim::Debates::DebatesController

  let!(:debate) { create(:debate, start_time: start_time, end_time: end_time) }
  let(:start_time) { Time.zone.local(2001, 1, 1, 11, 0, 0) }
  let(:end_time) { start_time.advance(hours: 2) }
  let(:model) { debate }
  let(:the_cell) { cell("decidim/debates/debate_m", debate, context: { show_space: show_space }) }
  let(:cell_html) { the_cell.call }

  context "when rendering" do
    let(:show_space) { false }

    it "shows the date in correct format" do
      expect(cell_html).to have_css(".card__icondata .card-data__item strong", text: "January 01, 2001")
      expect(cell_html).to have_css(".card__icondata .card-data__item", text: "11:00 AM - 01:00 PM")
    end
  end
end
