# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sms
    module Twilio
      describe DeliveriesController, type: :controller do
        routes { Decidim::Sms::Twilio::Engine.routes }
        include Decidim::Sms::Twilio::TokenGenerator

        let(:organization) { create(:organization) }
        let(:params) { { token: "DummyToken" } }

        context "when token is not valid" do
          let(:token) { "FakeToken" }

          before do
            request.env["decidim.current_organization"] = organization
            post :update, params: { token: token }
          end

          it "raises error" do
            expect(response).to have_http_status(:found)
          end
        end

        context "when token is valid" do
          let(:token) { generate_token(organization.host) }
          let(:sid) { "Dummysid" }
          let!(:delivery) { Decidim::Sms::Twilio::Delivery.create(sid: sid, status: "") }

          before do
            allow(JSON).to receive(:parse).and_return({ "sid": "Dummysid", "status": "Foo" })
            request.env["decidim.current_organization"] = organization
            post :update, params: { token: token }
          end

          it "updates delivery" do
            expect(response).to have_http_status(:no_content)
            expect(Delivery.last.status).to eq "Foo"
          end
        end
      end
    end
  end
end
