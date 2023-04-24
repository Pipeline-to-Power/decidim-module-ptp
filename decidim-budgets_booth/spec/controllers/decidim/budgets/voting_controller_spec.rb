# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe VotingController, type: :controller do
      routes { Decidim::Budgets::Engine.routes }

      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) do
        create(
          :budgets_component,
          settings: { workflow: "zip_code" }
        )
      end
      let(:vote) { "enabled" }
      let(:current_settings) { double(:current_settings, votes: vote) }
      let!(:budgets) { create_list(:budget, 3, component: component, total_budget: 100_000_000) }
      let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
      let(:projects) { create_list(:project, 3, budget: budgets.first, budget_amount: 45_000_000) }
      let(:current_workflow) { double(:current_workflow, voting_booth_forced?: zip_code?) }
      let(:zip_code?) { true }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        allow(controller).to receive(:current_settings).and_return(current_settings)
        allow(controller).to receive(:current_workflow).and_return(current_workflow)
      end

      describe "#index" do
        context "when not zip code workflow" do
          let!(:zip_code?) { false }

          before do
            component.update(settings: { workflow: "foo" })
          end

          it "redirects user" do
            get :index, params: { budget_id: budgets.last.id }
            expect(response).to redirect_to("/")
            expect(flash[:warning]).to have_content("You are not allowed to perform this action.")
          end
        end

        context "when voting is not open" do
          let!(:vote) { "foo" }

          it "redirects the user with proper message" do
            get :index, params: { budget_id: budgets.last.id }
            expect(response).to redirect_to(decidim_budgets.budget_projects_path(budgets.last))
            expect(flash[:warning]).to have_content("Voting is not allowed.")
          end
        end

        context "when not singed in" do
          it "redirects to the sign in page" do
            get :index, params: { budget_id: budgets.last.id }
            expect(response).to redirect_to("/users/sign_in")
          end
        end

        context "when voted that budget" do
          let!(:order) { create(:order, :with_projects, user: user, budget: budgets.last) }

          before do
            order.update!(checked_out_at: Time.current)
            sign_in user, scope: :user
          end

          it "redirects the user" do
            get :index, params: { budget_id: budgets.last.id }
            expect(response).to redirect_to(decidim_budgets.budgets_path)
            expect(flash[:warning]).to have_content("You are not allowed to perform this action.")
          end
        end

        context "when all before actions checked" do
          before do
            allow(controller).to receive(:enforce_permission_to).and_return(true)
            sign_in user, scope: :user
          end

          it "renders the voting booth" do
            get :index, params: { budget_id: budgets.last.id }
            expect(response).to render_template(:index, layout: "decidim/budgets/voting_layout")
          end
        end
      end
    end
  end
end
