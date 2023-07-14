# frozen_string_literal: true

require "spec_helper"

describe Decidim::BudgetsBooth::OrdersControllerExtensions, type: :controller do
  controller(Decidim::Budgets::OrdersController) do
    include Decidim::BudgetsBooth::OrdersControllerExtensions
  end

  routes { Decidim::Budgets::Engine.routes }

  include_context "with scoped budgets"

  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:component) { create(:budgets_component, settings: component_settings.merge(workflow: "zip_code"), organization: organization) }
  let(:projects_count) { 5 }
  let!(:budgets) { create_list(:budget, 3, component: component, total_budget: 100_000_000) }
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:projects) { create_list(:project, 3, budget: budgets.first, budget_amount: 75_000_000) }
  let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "10004" }) }
  let!(:order) { create(:order, user: user, budget: budgets.first) }

  before do
    request.env["decidim.current_organization"] = organization
    request.env["decidim.current_user"] = user
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
    order.projects << projects.first
    order.save!
    allow(controller).to receive(:budget).and_return(budgets.first)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#checkout" do
    context "when command call returns ok" do
      it "sets thanks session and redirects the user" do
        post :checkout, params: { budget_id: budgets.first.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
        expect(response).to redirect_to(decidim_budgets.budgets_path)
        expect(session[:booth_thanks_message]).to be(true)
      end
    end

    context "when invalid" do
      before do
        # make order invalid
        projects.first.update!(budget_amount: 25_000_000)
      end

      it "redirects the user with flash message" do
        post :checkout, params: { budget_id: budgets.first.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
        expect(response).to redirect_to(decidim_budgets.budgets_path)
        expect(flash[:alert]).to have_content("There was a problem processing your vote")
      end
    end
  end

  describe "#show" do
    context "when order does not exist" do
      it "renders error" do
        expect do
          get :show, params: { budget_id: budgets.first.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
        end.to raise_error(ActionController::RoutingError)
      end
    end

    context "when order exists" do
      before do
        order.update!(checked_out_at: Time.current)
      end

      it "redirects the html requests" do
        get :show, params: { budget_id: budgets.first.id, component_id: component.id, participatory_process_slug: component.participatory_space.slug }
        expect(response).to redirect_to(decidim_budgets.budgets_path)
      end
    end
  end
end
