# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe UserDataController, type: :controller do
      routes { Decidim::Budgets::Engine.routes }

      include_context "with scoped budgets"
      let(:projects_count) { 5 }
      let(:organization) { component.organization }
      let(:user) { create(:user, :confirmed, organization: organization) }
      let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
      let(:vote) { "enabled" }
      let(:current_settings) { double(:current_settings, votes: vote) }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        allow(controller).to receive(:current_settings).and_return(current_settings)
      end

      context "when not zip_code workflow" do
        it "redirects the user with error message" do
          get :new
          expect(response).to redirect_to("/")
          expect(flash[:warning]).to have_content("You are not allowed to perform this action.")
        end
      end

      context "when zip code workflow" do
        before do
          component.update(settings: { workflow: "zip_code" })
        end

        context "when not authenticated" do
          it "redirects to the login page" do
            get :new
            expect(response).to redirect_to("/users/sign_in")
          end
        end

        context "when voted" do
          let!(:order) { create(:order, :with_projects, user: user, budget: budgets.first) }
          let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "10004" }) }

          before do
            order.update!(checked_out_at: Time.current)
            sign_in user, scope: :user
          end

          it "redirects to the root path" do
            get :new
            expect(response).to redirect_to("/")
            expect(flash[:warning]).to have_content("You can not change your ZIP code after started voting. Delete all of your votes first.")
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
            expect(flash[:warning]).to have_content("You can not set your ZIP code when the voting is not open.")
          end
        end

        context "when zip code workflow, voting open, not voted, and login" do
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
