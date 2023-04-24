# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::CreateBudget do
  include ::Decidim::BudgetsBooth::CreateBudgetExtensions
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let!(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "budgets" }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:scope) { create :scope, organization: organization }
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
      current_component: current_component,
      current_organization: organization
    )
  end

  let(:invalid) { false }

  let(:budget) { Decidim::Budgets::Budget.last }

  context "when image is attached" do
    it "adds main image to the budget" do
      subject.call
      expect(budget.main_image.try(:blob)).to be_a(ActiveStorage::Blob)
    end
  end

  context "when image is not attached" do
    let(:main_image) { nil }

    it "does not add main image to the budget" do
      subject.call
      expect(budget.main_image.try(:blob)).to be_nil
    end
  end
end
