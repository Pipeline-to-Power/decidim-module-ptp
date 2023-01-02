# frozen_string_literal: true

require "spec_helper"

module Decidim::Smsauth
  describe VerificationCodeForm do
    subject(:form) { described_class.from_params(attributes) }

    let(:phone_number) { 456_789_012 }
    let(:phone_country) { "FI" }
    let(:verification) { "456_789" }

    let(:attributes) do
      {
        phone_number: phone_number,
        phone_country: phone_country,
        verification: verification
      }
    end

    it { is_expected.to be_valid }

    context "when verification code is not present" do
      let(:verification) { nil }

      it { is_expected.not_to be_valid }
    end
  end
end
