# frozen_string_literal: true

require "spec_helper"

module Decidim::Smsauth
  describe OmniauthForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:context) { { current_organization: organization } }

    let(:phone_number) { 123_456_789_012 }
    let(:phone_country) { "FI" }
    let(:organization) { create(:organization) }
    let(:attributes) do
      {
        phone_number: phone_number,
        phone_country: phone_country,
        organization: organization
      }
    end

    it { is_expected.to be_valid }

    describe "phone number" do
      context "when phone number is not present" do
        let(:phone_number) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the phone is not digit" do
        let(:phone_number) { "dummy string" }

        it { is_expected.not_to be_valid }
      end

      context "when negative number" do
        let(:phone_number) { -123_456_789_012 }

        it { is_expected.not_to be_valid }
      end
    end

    describe "when the phone country does not present" do
      let(:phone_country) { nil }

      it { is_expected.not_to be_valid }
    end
  end
end
