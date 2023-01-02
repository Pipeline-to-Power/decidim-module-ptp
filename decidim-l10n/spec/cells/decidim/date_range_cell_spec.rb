# frozen_string_literal: true

require "spec_helper"

describe Decidim::DateRangeCell, type: :cell do
  controller Decidim::Debates::DebatesController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/date_range", model) }
  let(:model) { { start: start_time, end: end_time } }
  let(:start_time) { Time.zone.local(2001, 1, 1, 11, 0, 0) }
  let(:end_time) { start_time.advance(hours: 2) }

  it "renders a Date card in correct format" do
    expect(subject).to have_css(".extra__date", text: "01")
    expect(subject).to have_css(".extra__date .extra__month", text: "January 2001")
    expect(subject).to have_css(".extra__time", text: "11:00 AM - 01:00 PM")
  end

  context "when start and end time are on different dates" do
    let(:end_time) { start_time.advance(months: 1, days: 2, hours: 2) }

    it "renders the two dates and times" do
      expect(subject).to have_css(".extra__date", text: "01")
      expect(subject).to have_css(".extra__date .extra__month", text: "January 2001")
      expect(subject).to have_css(".extra__time", text: "11:00 AM")
      expect(subject).to have_css(".extra__date", text: "03")
      expect(subject).to have_css(".extra__date .extra__month", text: "February 2001")
      expect(subject).to have_css(".extra__time", text: "01:00 PM")
    end
  end

  context "when start and end time are on different years" do
    let(:end_time) { start_time.advance(years: 1, months: 1, days: 2, hours: 2) }

    it "renders two year elements" do
      expect(subject).to have_css(".extra__date", text: "01")
      expect(subject).to have_css(".extra__date .extra__month", text: "January 2001")
      expect(subject).to have_css(".extra__time", text: "11:00 AM")
      expect(subject).to have_css(".extra__date", text: "03")
      expect(subject).to have_css(".extra__date .extra__month", text: "February 2002")
      expect(subject).to have_css(".extra__time", text: "01:00 PM")
    end
  end
end
