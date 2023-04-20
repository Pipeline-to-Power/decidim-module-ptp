# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::Workflows::ZipCode do
  subject { described_class.new(component, user) }

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, organization: organization) }
  let!(:user) { create(:user, organization: organization) }

  describe "#vote_allowed?" do
    let!(:allowed_budget) { create(:budget, component: component, scope: subscopes.first) }
    let!(:not_allowed_budget) { create(:budget, component: component, scope: subscopes.second) }

    include_context "with scopes"
    include_context "with user_data"

    context "when user zip code is blank" do
      before do
        user_data.update(metadata: { zip_code: "" })
      end

      it "returns false" do
        expect(subject).not_to be_vote_allowed(not_allowed_budget, consider_progress: true)
      end
    end

    context "when user zip code presents" do
      before do
        user_data.update(metadata: { zip_code: "10004" })
      end

      it "returns false for not_allowed_budget" do
        expect(subject).not_to be_vote_allowed(not_allowed_budget, consider_progress: true)
      end

      it "returns true for allowed_budget" do
        expect(subject).to be_vote_allowed(allowed_budget, consider_progress: true)
      end
    end
  end

  describe "#budgets" do
    let!(:budgets) { create_list(:budget, 3, component: component) }

    let(:scope_manager) { instance_double(Decidim::BudgetsBooth::ScopeManager) }

    before do
      allow(::Decidim::BudgetsBooth::ScopeManager).to receive(:new).and_return(scope_manager)
      allow(scope_manager).to receive(:user_zip_code).with(user, component).and_return("dummy zip_code")
      allow(scope_manager).to receive(:zip_codes).with(budgets.first).and_return(["dummy zip_code"])
      allow(scope_manager).to receive(:zip_codes).with(budgets.second).and_return(["dummy zip_code"])
      allow(scope_manager).to receive(:zip_codes).with(budgets.last).and_return(["another code"])
    end

    it "returns the correct budgets list" do
      expect(subject.budgets).to include(budgets.first)
      expect(subject.budgets).to include(budgets.second)
      expect(subject.budgets).not_to include(budgets.last)
    end
  end

  describe "highlighted?" do
    let!(:budgets) { create_list(:budget, 3, component: component) }

    it "returs false" do
      result = subject.highlighted?(budgets.first)
      expect(result).to be_falsey
    end
  end
end
