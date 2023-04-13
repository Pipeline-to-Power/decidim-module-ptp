# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::ScopeManager do
  subject { described_class.new }

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, organization: organization) }

  describe "#zip_codes" do
    include_context "with scopes"

    let!(:first_budget) { create(:budget, component: component, scope: parent_scopes.first) }
    let!(:second_budget) { create(:budget, component: component, scope: subscopes.first) }

    it "returns correct zip_codes" do
      expect(subject.zip_codes(first_budget)).to match_array(%w(10000 10001 10002 10003 10004))
      expect(subject.zip_codes(second_budget)).to match_array(%w(10004 10005 10006 10007 10008 10009 10010))
    end
  end

  describe "user_zip_code" do
    context "when user does not exist" do
      it "returns flase" do
        expect(subject.user_zip_code(nil, component)).to be_falsey
      end
    end

    context "when user exist" do
      include_context "with user_data"
      let!(:user) { create(:user, organization: organization) }
      let!(:another_component) { create(:budgets_component, organization: organization) }

      before do
        user_data.update(metadata: { zip_code: "dummy metadata" })
      end

      it "returns the user_data" do
        expect(subject.user_zip_code(user, component)).to eq("dummy metadata")
        expect(subject.user_zip_code(user, another_component)).to be_nil
      end
    end
  end
end
