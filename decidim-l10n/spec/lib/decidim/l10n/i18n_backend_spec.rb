# frozen_string_literal: true

require "spec_helper"

describe Decidim::L10n::I18nBackend do
  subject { backend }

  let(:region) { :US }
  let(:backend) do
    described_class.new.tap do |be|
      be.region = region
    end
  end

  describe "#region" do
    subject { backend.region }

    it { is_expected.to eq(:US) }
  end

  describe "#region=" do
    it "does not allow configuring an unavailable region" do
      subject.region = :CA
      expect(subject.region).to eq(:US)
    end

    it "allows configuring an available region" do
      subject.region = :US
      expect(subject.region).to eq(:US)
    end
  end

  describe "#available_regions" do
    subject { backend.available_regions }

    it "returns the available region configurations" do
      expect(subject).to eq([:US])
    end
  end

  describe "#available_locales" do
    subject { backend.available_locales }

    it { is_expected.to eq([I18n.locale]) }

    context "when the I18n locale is set to nil" do
      around do |example|
        I18n.with_locale(nil) { example.run }
      end

      it { is_expected.to eq([:en]) }
    end

    context "when the i18n locale is set to something else than :en" do
      around do |example|
        I18n.with_locale(:es) { example.run }
      end

      it { is_expected.to eq([:es]) }
    end
  end

  describe "#store_translations" do
    let(:translations) { { foo: "bar", baz: { biz: "buz" } } }

    it "stores the given translations even if the locale does not exist" do
      backend.store_translations(:XY, translations)
      expect(backend.translations).to include(XY: translations)
    end

    context "with string keys" do
      let(:translations) { { "foo" => "bar", "baz" => { "biz" => "buz" } } }

      it "symbolizes the keys" do
        backend.store_translations(:XY, translations)
        expect(backend.translations).to include(XY: { foo: "bar", baz: { biz: "buz" } })
      end

      context "with skip_symbolize_keys" do
        it "stores the translations without symbolizing the keys" do
          backend.store_translations(:XY, translations, skip_symbolize_keys: true)
          expect(backend.translations).to include(XY: translations)
        end
      end
    end
  end

  describe "#translate" do
    shared_examples "working i18n region backend" do |locale|
      it "translates the locale strings correctly in #{locale}" do
        expect(backend.translate(locale, "date.formats.decidim_short")).to eq("%m/%d/%Y")
        expect(backend.translate(locale, "date.formats.default")).to eq("%m/%d/%Y")
        expect(backend.translate(locale, "time.formats.decidim_short")).to eq("%m/%d/%Y %I:%M %p")
        expect(backend.translate(locale, "time.formats.default")).to eq("%a, %d %b %Y %I:%M:%S %p %Z")
      end
    end

    it_behaves_like "working i18n region backend", :en
    it_behaves_like "working i18n region backend", :es
    it_behaves_like "working i18n region backend", :xy
  end

  # Note that the localization also translates the (abbreviated) month and day
  # names which is why this cannot be tested for unexisting locales.
  #
  # localize(locale, object, format = :default, options = EMPTY_HASH)
  describe "#localize" do
    let(:date) { Date.new(2022, 11, 15) }
    let(:time_am) { Time.zone.local(2022, 11, 15, 9, 30) }
    let(:time_pm) { Time.zone.local(2022, 11, 15, 21, 30) }

    it "localizes the date correctly in" do
      expect(backend.localize(:en, date, :decidim_short)).to eq("11/15/2022")
      expect(backend.localize(:en, date, :default)).to eq("11/15/2022")
      expect(backend.localize(:es, date, :decidim_short)).to eq("11/15/2022")
      expect(backend.localize(:es, date, :default)).to eq("11/15/2022")
    end

    it "localizes the time correctly in en" do
      expect(backend.localize(:en, time_am, :decidim_short)).to eq("11/15/2022 09:30 AM")
      expect(backend.localize(:en, time_pm, :default)).to eq("Tue, 15 Nov 2022 09:30:00 PM UTC")
    end

    it "localizes the time correctly in es" do
      expect(backend.localize(:es, time_am, :decidim_short)).to eq("11/15/2022 09:30 AM")
      expect(backend.localize(:es, time_pm, :default)).to eq("mar, 15 nov 2022 09:30:00 PM UTC")
    end
  end
end
