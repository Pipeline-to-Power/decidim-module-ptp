# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sms
    module Twilio
      describe Gateway do
        subject do
          described_class.new(phone_number, code, organization: organization)
        end

        let(:organization) { nil }
        let(:server) { "https://api.twilio.com" }
        let(:api_version) { "2010-04-01" }
        let(:api_key) { "dummykey" }
        let(:account_sid) { "dummysid" }
        let(:auth_token) { "dummytoken" }
        let(:twilio_sender) { "1234567890" }
        let(:phone_number) { "+3585478373617" }
        let(:sid) { "Dummy sms id" }

        describe "#deliver_code" do
          let!(:phone_number) { "+123456789" }
          let!(:code) { "Dummy code" }
          let!(:status) { "qeued" }
          let(:body) { nil }
          let(:dummy_response) do
            %({
              "account_sid": "#{account_sid}",
              "status": "#{status}",
              "to": "#{phone_number}",
              "sid": "#{sid}",
              "from": "#{phone_number}",
              "api_version": "#{api_version}"
            })
          end
          let(:http_status) { 200 }

          before do
            allow(Rails.application.secrets).to receive(:twilio).and_return({ twilio_account_sid: account_sid, twilio_auth_token: auth_token, twilio_sender: twilio_sender })
            req = stub_request(:post, "https://api.twilio.com/#{api_version}/Accounts/#{account_sid}/Messages.json")
            req.with(body: body) if body
            req.to_return(body: dummy_response, status: http_status)
          end

          context "when everything is ok" do
            it "sends the message & updates the status" do
              expect do
                subject.deliver_code
              end.to change(Decidim::Sms::Twilio::Delivery, :count).from(0).to(1)
              action = Decidim::Sms::Twilio::Delivery.first
              expect(action.status).to eq(status)
            end

            context "with an organization" do
              let(:organization) { create(:organization) }
              let(:body) do
                hash_including(
                  "Body" => code,
                  "From" => twilio_sender,
                  "StatusCallback" => %r{http://#{organization.host}/sms/twilio/delivery\?token=[a-f0-9]{32}},
                  "To" => phone_number
                )
              end

              it "sends the message with the correct callback URL" do
                expect do
                  subject.deliver_code
                end.to change(Decidim::Sms::Twilio::Delivery, :count).from(0).to(1)
              end
            end
          end

          context "when there is an error" do
            let(:http_status) { 400 }
            let(:decidim_error_code) { nil }
            let(:error_details) { "" }
            let(:error_message) { "" }
            let(:error_more_info) { "" }
            let(:dummy_response) do
              %({
                "code": #{error_code},
                "details": "#{error_details}",
                "message": "#{error_message}",
                "error_more_info": "#{error_more_info}"
              })
            end

            shared_examples "twilio REST error" do
              it "raises the correct error" do
                expect { subject.deliver_code }.to raise_error do |error|
                  expect(error).to be_a(Decidim::Sms::Twilio::TwilioGatewayError)
                  expect(error.error_code).to eq(decidim_error_code)
                end
              end

              it "logs the error" do
                allow(Rails.logger).to receive(:error)
                expect(Rails.logger).to receive(:error).with("Twilio Error: #{error_code}")
                expect { subject.deliver_code }.to raise_error(Decidim::Sms::Twilio::TwilioGatewayError)
              end
            end

            context "with invalid to number" do
              let(:error_code) { 21_211 }
              let(:decidim_error_code) { :invalid_to_number }

              it_behaves_like "twilio REST error"
            end

            context "with invalid from number" do
              let(:error_code) { 21_606 }
              let(:decidim_error_code) { :invalid_from_number }

              it_behaves_like "twilio REST error"
            end

            context "with invalid geo permissions" do
              let(:error_code) { 21_408 }
              let(:decidim_error_code) { :invalid_geo_permission }

              it_behaves_like "twilio REST error"
            end

            context "with unknwown error" do
              let(:error_code) { 999_999_999 }
              let(:decidim_error_code) { :unknown }

              it_behaves_like "twilio REST error"
            end
          end
        end
      end
    end
  end
end
