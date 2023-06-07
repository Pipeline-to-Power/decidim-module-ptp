# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe CreateUserData do
      subject { described_class.new(form, zip_codes) }

      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:affirm_statements_are_correct) { true }
      let(:zip_codes) { %w(foo bar baz) }
      let(:zip_code) { "" }
      let(:component) do
        create(
          :budgets_component,
          settings: { workflow: "zip_code" }
        )
      end

      let(:form) do
        double(
          invalid?: invalid?,
          user: user,
          zip_code: zip_code,
          affirm_statements_are_correct: affirm_statements_are_correct,
          component: component
        )
      end

      context "when invalid" do
        let(:invalid?) { true }

        it { is_expected.to broadcast(:invalid) }
      end

      context "when form is valid" do
        let(:invalid?) { false }

        context "when zip code is not included" do
          let(:zip_code) { "quox" }

          it { is_expected.to broadcast(:invalid) }
        end

        context "when zip code included" do
          let(:zip_code) { "baz" }

          context "when user does not exist" do
            it "creates the user and broadcasts ok" do
              expect { subject.call }.to change(Decidim::Budgets::UserData, :count).by(1)
            end
          end

          context "when user data exists" do
            let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "quox" }) }
            let(:zip_code) { "foo" }

            it "updates the user data" do
              subject.call
              user_data = Decidim::Budgets::UserData.last
              expect(Decidim::Budgets::UserData.count).to eq(1)
              expect(user_data.metadata["zip_code"]).to eq("foo")
            end
          end
        end
      end
    end
  end
end
