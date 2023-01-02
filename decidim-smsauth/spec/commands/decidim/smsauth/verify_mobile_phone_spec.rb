# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Smsauth::VerifyMobilePhone do
    subject { described_class.new(form, data) }

    let(:phone_number) { "+35812345" }
    let(:phone_country) { "FI" }
    let(:verification) { "1234567" }
    let(:verification_code) { verification }
    let(:invalid?) { true }
    let(:sent_at) { Time.current }
    let(:data) do
      {
        verification_code: verification_code,
        sent_at: sent_at,
        country: form.phone_country,
        phone: form.phone_number,
        verified: false
      }
    end
    let(:form) do
      double(
        invalid?: invalid?,
        phone_number: phone_number,
        phone_country: phone_country,
        verification: verification
      )
    end

    context "when invalid" do
      it { is_expected.to broadcast(:invalid) }
    end

    context "when form valid" do
      let(:invalid?) { false }

      context "when code does not match" do
        let(:verification_code) { "879754" }

        it "broadcasts invalid" do
          expect(subject.call).to broadcast(:invalid)
        end
      end

      context "when validation period fails" do
        let(:sent_at) { 10.minutes.ago }

        it "broadcasts invalid" do
          expect(subject.call).to broadcast(:invalid)
        end
      end
    end
  end
end
