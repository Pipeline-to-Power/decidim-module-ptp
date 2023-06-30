# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe UserDataForm do
      subject(:form) { described_class.from_params(attributes) }

      let(:zip_code) { "dummy metadata" }
      let(:organization) { create(:organization) }
      let(:affirm_statements_are_correct) { true }
      let(:user) { create(:user, :confirmed, organization: organization) }
      let(:component) { create(:budgets_component) }

      let(:attributes) do
        {
          zip_code: zip_code,
          affirm_statements_are_correct: affirm_statements_are_correct,
          user: user,
          component: component
        }
      end

      it { is_expected.to be_valid }

      context "when no user" do
        let!(:user) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when no component" do
        let!(:component) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when statement is not affirmed" do
        let!(:affirm_statements_are_correct) { false }

        it { is_expected.not_to be_valid }
      end

      context "when no metadata" do
        let!(:zip_code) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
