# frozen_string_literal: true

require "spec_helper"

module Decidim::Smsauth
  describe AccountFormExtensions do
    subject do
      Decidim::AccountForm.new(
        phone_number: phone_number,
        phone_country: phone_country
      )
    end

    let(:phone_number) { "457787741" }
    let(:phone_country) { "FI" }

    describe "#mask_number" do
      it "masks the number" do
        expect(subject.mask_number).to eq "+358*****741"
      end
    end
  end
end
