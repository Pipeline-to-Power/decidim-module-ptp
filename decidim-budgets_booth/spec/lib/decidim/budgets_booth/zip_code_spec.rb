# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::ZipCode do
  subject do
    described_class do
      include Decidim::BudgetsBooth::ZipCode
    end.new(component, user)
  end

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
        user_data.update(metadata: "")
      end

      it "returns false" do
        expect(subject).not_to be_vote_allowed(not_allowed_budget, consider_progress: true)
      end
    end

    context "when user zip code presents" do
      before do
        user_data.update(metadata: "1004")
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
    let(:vote_allowed?) { double.as_null_object }

    before do
      allow(subject).to receive(:vot_allowed?).and_return(true)
    end

    it "returns the correct budgets list" do
      expect(subject.budgets).to include(budgets.first)
      expect(subject.budgets).to include(budgets.second)
      expect(subject.budgets).not_to include(budgets.last)
    end
  end
end
