# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Smsauth
    module Verification
      describe AuthorizationsController, type: :controller do
        routes { Decidim::Smsauth::Verification::Engine.routes }
        let(:phone_country) { "FI" }
        let(:phone_number) { "4577541254" }
        let!(:ungranted_authorization) do
          create(
            :authorization,
            :pending,
            user: user,
            name: "smsauth_id",
            metadata: { phone_number: phone_number, phone_country: phone_country },
            unique_id: "Dummy unique id",
            verification_metadata: { verification_code: "123456" },
            verification_attachment: nil
          )
        end

        describe "#resend_code" do
          include_context "with twilio gateway"
          include_context "with unauthorized user sign in"

          context "when session is still valid" do
            before do
              session[:last_attempt] = Time.current
            end

            it "does not send the sms" do
              put :resend_code, params: {
                user: user,
                handler_name: "smsauth_id",
                phone_number: phone_number,
                phone_country: phone_country,
                organization: organization
              }
              expect(flash[:error]).to be_present
              expect(response).to redirect_to("/smsauth_id/authorizations/edit")
            end
          end

          context "when session is expired" do
            let(:verification) { "44541254" }
            let!(:dummy_time) { 2.minutes.ago }

            before do
              session[:last_attempt] = dummy_time
            end

            it "does not send the sms" do
              put :resend_code, params: {
                user: user,
                handler_name: "smsauth_id",
                phone_number: phone_number,
                phone_country: phone_country
              }
              expect(flash[:notice]).to be_present
              expect(response).to redirect_to("/smsauth_id/authorizations/edit")
            end
          end
        end

        describe "#update" do
          include_context "with unauthorized user sign in"
          context "with correct code" do
            it "updates authorization" do
              put :update, params: {
                user: user,
                handler_name: "smsauth_id",
                phone_number: phone_number,
                phone_country: phone_country,
                verification_code: "123456"
              }
              user.reload
              ungranted_authorization.reload
              expect(user.phone_number).to eq "4577541254"
              expect(user.phone_country).to eq "FI"
              expect(ungranted_authorization).to be_granted
            end
          end
        end
      end
    end
  end
end
