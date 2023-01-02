# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Smsauth::RegisterByPhone do
    subject { described_class.new(form) }

    let(:name) { "dummy name" }
    let(:email) { "dummy_name@gmail.com" }
    let(:tos_agreement) { true }
    let(:phone_number) { "45678945612" }
    let(:phone_country) { "FI" }
    let(:newsletter) { true }
    let(:organization) { create(:organization) }
    let(:valid?) { true }
    let(:newsletter_at) { Time.current }
    let(:current_locale) { :en }

    let(:form) do
      double(
        valid?: valid?,
        name: name,
        email: email,
        phone_number: phone_number,
        phone_country: phone_country,
        newsletter: newsletter,
        organization: organization,
        tos_agreement: tos_agreement,
        newsletter_at: newsletter_at,
        current_locale: current_locale
      )
    end

    context "when invalid" do
      let(:valid?) { false }

      it { is_expected.to broadcast(:invalid) }
    end

    context "when valid" do
      context "when email is provided" do
        it "creates the user" do
          subject.call
          expect(User.count).to eq(1)
          expect(User.last.email).to eq(email)
        end
      end

      context "when email address is not provided" do
        let(:email) { nil }

        it "confirms the user if the email is already verified" do
          subject.call
          expect(User.count).to eq(1)
          expect(User.last.email).to match(/^smsauth-.+@\d+\.lvh\.me$/)
        end
      end
    end
  end
end
