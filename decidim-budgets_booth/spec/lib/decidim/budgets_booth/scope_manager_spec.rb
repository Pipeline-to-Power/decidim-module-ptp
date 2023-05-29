# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::ScopeManager do
  subject { described_class.new(component) }

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, settings: component_settings, organization: organization) }
  let(:component_settings) { { scopes_enabled: true, scope_id: parent_scope.id } }

  describe "#zip_codes_for" do
    include_context "with scopes"

    let!(:first_budget) { create(:budget, component: component, scope: parent_scope) }
    let!(:second_budget) { create(:budget, component: component, scope: subscopes.first) }

    it "returns correct zip_codes" do
      expect(subject.zip_codes_for(first_budget)).to match_array(
        [(10_000..10_004).to_a, (10_010..10_016).to_a, (10_020..10_027).to_a].flatten.map(&:to_s)
      )
      expect(subject.zip_codes_for(second_budget)).to match_array((10_000..10_004).to_a.map(&:to_s))
    end

    describe "performance" do
      # Disable transactional tests to optimize the query performance and ensure
      # consistent results. With transactional queries, there may be fluctuation
      # in the query performance.
      self.use_transactional_tests = false

      let(:parent_scope) { city }
      let!(:city) { create(:scope, organization: organization) }
      let!(:boroughs) { create_list(:scope, 10, parent: city, organization: organization) }
      let!(:neighborhoods) do
        [].tap do |list|
          boroughs.each do |parent|
            5.times do
              list << create(:scope, parent: parent, organization: organization)
            end
          end
        end
      end

      before do
        # Create the postal codes for all neighborhoods
        neighborhoods.each_with_index do |neighborhood, i|
          20.times do |j|
            postal = "#{(i + 1).to_s.rjust(2, "0")}#{j.to_s.rjust(3, "0")}"
            create(:scope, code: "#{i}_#{postal}", name: { en: postal }, parent: neighborhood)
          end
        end
      end

      after do
        # Because the transactional tests are disabled, we need to manually
        # clear the tables after the test.
        connection = ActiveRecord::Base.connection
        connection.disable_referential_integrity do
          connection.tables.each do |table_name|
            next if connection.select_value("SELECT COUNT(*) FROM #{table_name}").zero?

            connection.execute("TRUNCATE #{table_name} CASCADE")
          end
        end
      end

      it "performs fairly" do
        time_start = Time.zone.now
        expect(subject.zip_codes_for(city).count).to eq(1000)
        expect(Time.zone.now - time_start).to be < 0.1
      end
    end
  end

  describe "#user_zip_code" do
    let(:parent_scope) { create(:scope, organization: organization) }

    context "when user does not exist" do
      it "returns flase" do
        expect(subject.user_zip_code(nil)).to be_falsey
      end
    end

    context "when user exist" do
      include_context "with user data"

      let!(:user) { create(:user, organization: organization) }
      let!(:another_component) { create(:budgets_component, organization: organization) }

      before do
        user_data.update(metadata: { zip_code: "dummy metadata" })
      end

      it "returns the user_data" do
        expect(subject.user_zip_code(user)).to eq("dummy metadata")
      end

      it "does not return user data for another component" do
        expect(described_class.new(another_component).user_zip_code(user)).to be_nil
      end
    end

    context "with multiple processes or threads", :caching do
      # File cache store needed to persist the cache over multiple processes.
      let(:file_store) { ActiveSupport::Cache.lookup_store(:file_store, cache_location) }
      let(:cache_location) { Rails.root.join("tmp/test-file-cache-store") }
      let(:scope_manager) { Decidim::BudgetsBooth::ScopeManager.new(component) }

      let(:user) { create(:user, organization: organization) }
      let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "12345" }) }

      # Disable transactional tests to persist the data over multiple
      # processes.
      self.use_transactional_tests = false

      before do
        # Has to be set in order to use the actual memory store because the
        # runtime configuration has been already loaded with the :null_store
        # configuration at the testing environment.
        allow(Rails).to receive(:cache).and_return(file_store)
        Rails.cache.clear
      end

      after do
        FileUtils.rm_rf(cache_location)

        # Because the transactional tests are disabled, we need to manually
        # clear the tables after the test.
        connection = ActiveRecord::Base.connection
        connection.disable_referential_integrity do
          connection.tables.each do |table_name|
            next if connection.select_value("SELECT COUNT(*) FROM #{table_name}").zero?

            connection.execute("TRUNCATE #{table_name} CASCADE")
          end
        end
      end

      it "does not persist the state in other processes" do
        expect(subject.user_zip_code(user)).to eq("12345")

        pid = Process.fork do
          subcomp = Decidim::Component.find(component.id)
          subsm = Decidim::BudgetsBooth::ScopeManager.new(subcomp)
          expect(subsm.user_zip_code(user)).to eq("12345")
          sleep 5
          expect(subsm.user_zip_code(user)).to eq("67890")
        end

        # Give enough time for the other process to do the first expectation
        sleep(2)
        user_data.destroy!
        create(:user_data, component: component, user: user, metadata: { zip_code: "67890" })

        Process.wait(pid)
        expect($CHILD_STATUS.exitstatus).to eq(0)
      end
    end
  end
end
