# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::UserData do
  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, organization: organization) }
  let(:user) { create(:user, organization: organization) }
  let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "12345" }) }

  let(:scope_manager) { Decidim::BudgetsBooth::ScopeManager.new(component) }

  describe "#create" do
    it "clears the cache" do
      expect(scope_manager.user_zip_code(user)).to eq("12345")

      user_data.destroy!
      create(:user_data, component: component, user: user, metadata: { zip_code: "67890" })
      expect(scope_manager.user_zip_code(user)).to eq("67890")
    end
  end

  describe "#update" do
    it "clears the cache" do
      expect(scope_manager.user_zip_code(user)).to eq("12345")

      user_data.update!(metadata: { zip_code: "67890" })
      expect(scope_manager.user_zip_code(user)).to eq("67890")
    end
  end

  describe "#destroy" do
    it "clears the cache" do
      expect(scope_manager.user_zip_code(user)).to eq("12345")

      user_data.destroy!
      expect(scope_manager.user_zip_code(user)).to be_nil
    end
  end
end
