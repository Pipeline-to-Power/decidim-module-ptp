# frozen_string_literal: true

require "spec_helper"

module Decidim::Smsauth
  describe UserRegistrationForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:name) { "dummy name" }
    let(:email) { "dummy_name@gmail.com" }
    let(:tos_agreement) { true }
    let(:phone_number) { "45678945612" }
    let(:phone_country) { "FI" }
    let(:newsletter) { true }
    let(:organization) { create(:organization) }
    let(:current_locale) { "es" }

    let(:context) { { current_organization: organization } }

    let(:attributes) do
      {
        name: name,
        email: email,
        tos_agreement: tos_agreement,
        phone_number: phone_number,
        phone_country: phone_country,
        newsletter: newsletter,
        current_locale: current_locale,
        organization: organization
      }
    end

    it { is_expected.to be_valid }

    describe "tos_agreement " do
      context "when nil" do
        let(:tos_agreement) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when not agreed" do
        let(:tos_agreement) { false }

        it { is_expected.not_to be_valid }
      end
    end

    describe "when organization is not present" do
      let(:organization) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when name is not present" do
      let(:name) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when organization is not present" do
      let(:organization) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when phone number is not present" do
      let(:phone_number) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when phone country is not present" do
      let(:phone_country) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "email address" do
      context "when not provided" do
        let(:email) { nil }

        it { is_expected.to be_valid }
      end

      context "when not unique" do
        let!(:user) { create(:user, organization: organization, email: email) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
