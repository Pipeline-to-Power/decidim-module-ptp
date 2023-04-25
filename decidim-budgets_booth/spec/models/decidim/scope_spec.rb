# frozen_string_literal: true

require "spec_helper"

describe Decidim::Scope do
  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, organization: organization, settings: component_settings) }
  let(:component_settings) { { scopes_enabled: true, scope_id: parent_scope.id } }

  let(:parent_scope) { create(:scope, organization: organization) }
  let!(:postal_scopes) do
    [].tap do |scopes|
      (10_000..10_005).each do |code|
        scopes << create(:scope, parent: parent_scope, name: { en: code.to_s }, code: "POSTAL_#{code}")
      end
    end
  end
  let(:scope_manager) { Decidim::BudgetsBooth::ScopeManager.new(component) }

  describe "#create" do
    it "clears the cache" do
      expect(scope_manager.zip_codes_for(parent_scope)).to match_array(%w(10000 10001 10002 10003 10004 10005))

      postal_scopes.last.destroy!
      create(:scope, parent: parent_scope, name: { en: "10006" }, code: "POSTAL_10006")
      expect(scope_manager.zip_codes_for(parent_scope)).to match_array(%w(10000 10001 10002 10003 10004 10006))
    end
  end

  describe "#update" do
    it "clears the cache" do
      expect(scope_manager.zip_codes_for(parent_scope)).to match_array(%w(10000 10001 10002 10003 10004 10005))

      postal_scopes.last.update!(name: { en: "10006" }, code: "POSTAL_10006")
      expect(scope_manager.zip_codes_for(parent_scope)).to match_array(%w(10000 10001 10002 10003 10004 10006))
    end
  end

  describe "#destroy" do
    it "clears the cache" do
      expect(scope_manager.zip_codes_for(parent_scope)).to match_array(%w(10000 10001 10002 10003 10004 10005))

      postal_scopes.last.destroy!
      expect(scope_manager.zip_codes_for(parent_scope)).to match_array(%w(10000 10001 10002 10003 10004))
    end
  end
end
