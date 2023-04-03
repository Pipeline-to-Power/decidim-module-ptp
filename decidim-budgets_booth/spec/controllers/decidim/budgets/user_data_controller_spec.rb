# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe UserDataController, type: :controller do
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

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        allow(controller).to receive(:current_settings).and_return(current_settings)
      end

      context "when not zip_code workflow" do
        before do
          component.update(settings: { workflow: "one" })
        end

        it "redirects the user with error message" do
          get :new
          expect(response).to redirect_to("/")
          expect(flash[:warning]).to have_content("You are not allowed to perform this action.")
        end
      end

      context "when zip code workflow" do
        context "when not authenticated" do
          it "redirects to the login page" do
            get :new
            expect(response).to redirect_to("/users/sign_in")
          end
        end

        context "when voted" do
          let!(:order) { create(:order, :with_projects, user: user, budget: budgets.first) }

          before do
            order.update(checked_out_at: Time.current)
            sign_in user, scope: :user
          end

          it "redirects to the budgets path" do
            puts "voted_any? value: #{controller.send(:voted_any?)}"
            get :new
            expect(response).to redirect_to(decidim_budgets.budgets_path)
            expect(flash[:warning]).to have_content("You can not change your zip code after started voting. Delete all of your votes first.")
          end
        end

        context "when voting not open" do
          let(:vote) { "finished" }

          before do
            sign_in user, scope: :user
          end

          it "redirects to the root path with error" do
            get :new
            expect(response).to redirect_to("/")
            expect(flash[:warning]).to have_content("You can not set your zip code when the voting is not open.")
          end
        end

        context "when zip code workflow, voting open, not voting, and login" do
          before do
            sign_in user, scope: :user
          end

          it "renders new page with voting layout" do
            get :new
            expect(response).to render_template(:new, layout: "decidim/budgets/voting_layout")
          end
        end
      end
    end
  end
end
