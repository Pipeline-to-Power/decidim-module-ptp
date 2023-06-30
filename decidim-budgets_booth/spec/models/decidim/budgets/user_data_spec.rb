# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::UserData do
  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, organization: organization) }
  let(:user) { create(:user, organization: organization) }
  let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "12345" }) }

  shared_examples "fetched through the scope manager" do
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

  it_behaves_like "fetched through the scope manager"

  context "when using the memory cache store", :caching do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

    before do
      # Has to be set in order to use the actual memory store because the
      # runtime configuration has been already loaded with the :null_store
      # configuration at the testing environment.
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end

    it_behaves_like "fetched through the scope manager"
  end
end
