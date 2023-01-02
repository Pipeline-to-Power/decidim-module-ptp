# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Smsauth
    describe OmniauthController, type: :controller do
      routes { Decidim::Smsauth::Engine.routes }
      include_context "when organization present"
      let(:verification_code) { "123456" }
      let(:sent_at) { Time.current }
      let(:country) { "FI" }
      let(:phone) { "455555555" }
      let(:verified) { false }
      let(:auth_session) do
        {
          "verification_code": verification_code,
          "sent_at": sent_at,
          "country": country,
          "phone": phone,
          "verified": verified
        }
      end

      before do
        request.env["devise.mapping"] = ::Devise.mappings[:user]
      end

      describe "#sms" do
        context "when unauthorized" do
          include_context "when signed-in"
          it_behaves_like "unauthorized action", :new
        end

        context "when authorized" do
          it "renders the content" do
            get :new
            expect(response).to render_template(:new)
          end
        end
      end

      describe "#registration" do
        context "when unauthorized" do
          include_context "when signed-in"
          it_behaves_like "unauthorized action", :registration
        end

        context "when authorized" do
          it "renders the content" do
            get :registration
            expect(response).to render_template(:registration)
          end
        end
      end

      describe "#user_registry" do
        context "when unauthorized" do
          include_context "when signed-in"
          it_behaves_like "unauthorized action", :user_registry
        end
      end

      describe "#update" do
        include_context "when signed-in"
        before do
          request.session["authentication_attempt"] = auth_session
        end

        it "updates authorization and user info" do
          expect do
            post :update, params: {
              phone_number: phone,
              phone_country: country,
              verification: verification_code
            }
          end.to change(Decidim::Authorization.where(user: user), :count).by(1)
          user.reload
          expect(user.phone_number).to eq(phone)
          expect(Decidim::Authorization.find_by(user: user).granted_at).not_to be_nil
        end
      end

      describe "#send_message" do
        include_context "with twilio gateway"
        it "sets the authorization sessions" do
          expect(session["authentication_attempt"]).to be_nil
          post :send_message, params: {
            phone_number: phone,
            phone_country: country
          }
          expect(session["authentication_attempt"]).to include({ "country": country, "phone": phone.to_i, "verified": false })
        end
      end

      describe "#authenticate_user" do
        before do
          request.session["authentication_attempt"] = auth_session
        end

        context "when the first time login" do
          it "redirects to the registeration page" do
            post :authenticate_user, params: {
              phone_number: phone,
              phone_country: country,
              verification: verification_code
            }
            expect(response).to redirect_to(users_auth_sms_registration_path)
          end
        end

        context "when the user has created an account before" do
          let!(:user) { create(:user, organization: organization, phone_number: phone, phone_country: country) }

          it "logs in and redirects the user" do
            post :authenticate_user, params: {
              phone_number: phone,
              phone_country: country,
              verification: verification_code
            }
            expect(response).to redirect_to("/authorizations")
          end
        end
      end

      describe "#resend_code" do
        include_context "with twilio gateway"
        before do
          request.session["authentication_attempt"] = auth_session
        end

        context "when resend_code_allowed" do
          let!(:sent_at) { 2.minutes.ago }

          before do
            request.session["authentication_attempt"][:sent_at] = sent_at
          end

          it "resends the verification code" do
            post :resend_code, params: {
              phone_number: phone,
              phone_country: country
            }
            expect(flash[:notice]).to be_present
            expect(auth_session[:sent_at]).to eq(sent_at)
            expect(auth_session[:verification_code]).to eq(verification_code)
            expect(response).to redirect_to(users_auth_sms_verification_path)
          end
        end

        context "when not allowed to resend code" do
          it "does not send the code" do
            post :resend_code, params: {
              phone_number: phone,
              phone_country: country
            }
            expect(flash[:error]).to be_present
            expect(response).to redirect_to(users_auth_sms_verification_path)
          end
        end
      end
    end
  end
end
