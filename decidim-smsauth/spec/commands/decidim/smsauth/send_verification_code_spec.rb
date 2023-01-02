# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Smsauth::SendVerificationCode do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:phone_number) { "456789012" }
    let(:phone_country) { "FI" }
    let(:verification) { "456789" }
    let(:invalid?) { false }

    let(:form) do
      double(
        invalid?: invalid?,
        organization: organization,
        phone_number: phone_number,
        phone_country: phone_country,
        verification: verification
      )
    end

    context "when invalid" do
      let(:invalid?) { true }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end
    end

    context "when form is valid" do
      let(:gatewayer) { instance_double(Decidim::Sms::Twilio::Gateway, phone_number: "+358#{phone_number}", code: verification, organization: organization) }

      before do
        allow(Decidim::Sms::Twilio::Gateway).to receive(:new).and_return(gatewayer)
        allow(SecureRandom).to receive(:random_number).and_return(verification)
      end

      context "when successfully send verification code" do
        before do
          allow(gatewayer).to receive(:deliver_code).and_return(true)
        end

        it "broadcasts ok with verification code" do
          expect(subject.call).to broadcast(:ok, verification)
        end
      end

      context "when could not send verification code" do
        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(::Decidim::Smsauth::SendVerificationCode).to receive(:send_verification!).and_return(false)
          # rubocop:enable RSpec/AnyInstance
        end

        it "broadcasts invalid" do
          expect(subject.call).to broadcast(:invalid)
        end
      end
    end
  end
end
