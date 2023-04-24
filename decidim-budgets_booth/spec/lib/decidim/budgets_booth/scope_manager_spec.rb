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
  end
end
