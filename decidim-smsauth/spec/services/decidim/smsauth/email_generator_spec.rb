# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Smsauth
    describe EmailGenerator do
      subject { described_class.new(organization, phone_country, phone_number) }

      let(:organization) { create(:organization) }
      let(:phone_country) { "FI" }
      let(:phone_number) { "+358456789012" }

      it "generates the email with correct format" do
        expect(subject.generate).to match(/^smsauth-\w*@#{organization.host}$/)
      end
    end
  end
end
