# frozen_string_literal: true

RSpec.shared_context "when signed-in" do
  include_context "when organization present"

  let(:user) { create(:user, :confirmed, organization: organization, phone_number: "4578945421", phone_country: "FI") }

  before do
    sign_in user, scope: :user
  end
end

RSpec.shared_context "with unauthorized user sign in" do
  include_context "when organization present"
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    sign_in user, scope: :user
  end
end

RSpec.shared_context "when organization present" do
  let(:organization) { create(:organization) }

  before do
    request.env["decidim.current_organization"] = organization
  end
end

RSpec.shared_context "with twilio gateway" do
  let(:server) { "https://api.twilio.com" }
  let(:api_version) { "2010-04-01" }
  let(:api_key) { "dummykey" }
  let(:account_sid) { "dummysid" }
  let(:auth_token) { "dummytoken" }
  let(:twilio_sender) { "1234567890" }
  let(:phone_number) { "+3585478373617" }
  let(:sid) { "Dummy sms id" }
  let!(:code) { "1234567" }
  let!(:status) { "qeued" }
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

  before do
    allow(Decidim::Smsauth).to receive(:default_countries).and_return(%w(LT LU LV))
    allow(Rails.application.secrets).to receive(:twilio).and_return({ twilio_account_sid: account_sid, twilio_auth_token: auth_token, twilio_sender: twilio_sender })
    stub_request(:post, "https://api.twilio.com/#{api_version}/Accounts/#{account_sid}/Messages.json")
      .to_return(body: dummy_response)
    allow(SecureRandom).to receive(:random_number).and_return(1_234_567)
  end
end
