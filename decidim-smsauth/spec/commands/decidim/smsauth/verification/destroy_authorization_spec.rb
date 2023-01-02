# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Smsauth::Verification::DestroyAuthorization do
    subject { described_class.new(authorization) }

    let!(:authorization) { create(:authorization, :granted) }

    describe "#call" do
      it "destroys the authorization" do
        expect(Decidim::Authorization.count).to eq(1)
        expect { subject.call }.to change(Decidim::Authorization, :count).by(-1)
      end
    end
  end
end
