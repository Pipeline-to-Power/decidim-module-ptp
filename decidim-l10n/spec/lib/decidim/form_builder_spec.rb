# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

describe Decidim::FormBuilder do
  let(:helper) { Class.new(ActionView::Base).new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }
  let(:snippets) { double }
  let(:available_locales) { %w(en es) }
  let(:uploader) { Decidim::ApplicationUploader }
  let(:organization) { create(:organization) }

  let(:resource) do
    klass = Class.new do
      cattr_accessor :current_organization

      def self.model_name
        ActiveModel::Name.new(self, nil, "dummy")
      end

      # 0.27->
      extend ActiveModel::Translation
      include ActiveModel::Model
      include Decidim::AttributeObject::Model
      include Decidim::TranslatableAttributes

      # 0.26
      # include Virtus.model
      # include ActiveModel::Validations
      # include Decidim::TranslatableAttributes

      attribute :start_time, DateTime

      validates :start_time, presence: true

      def organization
        current_organization
      end
    end
    klass.current_organization = organization
    klass.new
  end

  let(:builder) { Decidim::FormBuilder.new(:resource, resource, helper, {}) }
  let(:parsed) { Nokogiri::HTML(output) }

  before do
    allow(Decidim).to receive(:available_locales).and_return available_locales
    allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
    allow(helper).to receive(:snippets).and_return(snippets)
    allow(snippets).to receive(:any?).with(:decidim_l10n_picker).and_return(false)
    allow(snippets).to receive(:add)
    allow(snippets).to receive(:for)
  end

  describe "datetime_field" do
    let(:output) do
      builder.datetime_field :start_time
    end

    it "sets the autocomplete attribute to off by default" do
      expect(parsed.css("input").first["autocomplete"]).to eq("off")
    end

    context "with autocomplete disabled" do
      let(:output) do
        builder.datetime_field :start_time, autocomplete: nil
      end

      it "does not set the autocomplete attribute" do
        expect(parsed.css("input").first["autocomplete"]).to be_nil
      end
    end

    context "when the start_time is set as ActiveSupport::TimeWithZone" do
      before do
        resource.start_time = Time.parse("2017-02-01T15:00:00.000Z").in_time_zone("UTC")
      end

      it { expect(resource.start_time).to be_a(ActiveSupport::TimeWithZone) }

      it "formats the start date correctly" do
        expect(parsed.css("input").first.attr("data-startdate")).to eq("02/01/2017 03:00 PM")
      end

      context "with another timezone", tz: "Helsinki" do
        it "formats the start date in the original time zone" do
          # Note: this case is correct because it should preserve the zone stored within the value itself.
          expect(parsed.css("input").first.attr("data-startdate")).to eq("02/01/2017 03:00 PM")
        end
      end
    end

    # 0.27->
    # context "when the start_time is set as Time" do
    #   before do
    #     resource.start_time = Time.parse("2017-02-01T15:00:00.000Z")
    #   end

    #   it { expect(resource.start_time).to be_a(Time) }

    #   it "formats the start date correctly" do
    #     expect(parsed.css("input").first.attr("data-startdate")).to eq("02/01/2017 03:00 PM")
    #   end

    #   context "with another timezone", tz: "Helsinki" do
    #     it "formats the start date in the correct time zone" do
    #       expect(parsed.css("input").first.attr("data-startdate")).to eq("02/01/2017 05:00 PM")
    #     end
    #   end
    # end

    # 0.27->
    # context "when the start_time is set as DateTime" do
    #   before do
    #     resource.start_time = DateTime.parse("2017-02-01T15:00:00.000Z") # _rubocop:disable Style/DateTime
    #     raise resource.start_time.class.inspect
    #   end

    #   it { expect(resource.start_time).to be_a(DateTime) }

    #   it "formats the start date correctly" do
    #     expect(parsed.css("input").first.attr("data-startdate")).to eq("02/01/2017 03:00 PM")
    #   end

    #   context "with another timezone", tz: "Helsinki" do
    #     it "formats the start date in the correct time zone" do
    #       expect(parsed.css("input").first.attr("data-startdate")).to eq("02/01/2017 05:00 PM")
    #     end
    #   end
    # end

    context "when the resource has errors" do
      before do
        resource.valid?
      end

      it "renders the input with the proper class" do
        expect(parsed.css("input.is-invalid-input")).not_to be_empty
      end
    end
  end
end
