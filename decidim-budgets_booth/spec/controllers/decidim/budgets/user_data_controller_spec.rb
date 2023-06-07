# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe UserDataController, type: :controller do
      routes { Decidim::Budgets::Engine.routes }

      include_context "with scoped budgets"

      let(:projects_count) { 5 }
      let(:user) { create(:user, :confirmed, organization: organization) }
      let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
      let(:votes) { "enabled" }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      context "when not zip_code workflow" do
        it "redirects the user with error message" do
          get :new
          expect(response).to redirect_to("/")
          expect(flash[:warning]).to have_content("You are not allowed to perform this action.")
        end
      end

      context "when zip code workflow" do
        let(:active_step_id) { component.participatory_space.active_step.id }

        before do
          component.update!(settings: component_settings.merge(workflow: "zip_code"), step_settings: { active_step_id => { votes: votes } })
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
          let(:votes) { "finished" }

          before do
            sign_in user, scope: :user
          end

          it "redirects to the root path with warning" do
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
