# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::UpdateBudget do
  include ::Decidim::BudgetsBooth::UpdateBudgetExtensions
  subject { described_class.new(form, budget) }

  let(:budget) { create :budget }
  let(:scope) { create :scope, organization: budget.organization }
  let(:user) { create :user, :admin, :confirmed, organization: budget.organization }
  let(:main_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "city.jpeg",
      content_type: "image/jpeg"
    )
  end

  let(:form) do
    double(
      invalid?: invalid,
      weight: 0,
      title: { en: "title" },
      description: { en: "description" },
      total_budget: 100_000_000,
      scope: scope,
      current_user: user,
      main_image: main_image,
      current_component: budget.component,
      current_organization: budget.organization
    )
  end

  let(:invalid) { false }

  context "when image is attached" do
    it "adds main image to the budget" do
      expect(budget.main_image.blob).to be_nil
      subject.call
      expect(budget.main_image.blob).to be_a(ActiveStorage::Blob)
    end
  end

  context "when image is not attached" do
    let(:main_image) { nil }

    it "does not add main image to the budget" do
      subject.call
      expect(budget.main_image.blob).to be_nil
    end
  end
end
