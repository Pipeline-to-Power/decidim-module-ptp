# frozen_string_literal: true

require "spec_helper"

module Decidim
  module BudgetsBooth
    describe BudgetsControllerExtensions, type: :controller do
      controller(::Decidim::Budgets::BudgetsController) do
        include BudgetsControllerExtensions
      end

      describe "#index" do
        routes { Decidim::Budgets::Engine.routes }

        let(:user) { create(:user, :confirmed, organization: component.organization) }
        let(:component) do
          create(
            :budgets_component,
            settings: { workflow: "zip_code", votes: "enabled" }
          )
        end
        let!(:budgets) { create_list(:budget, 3, component: component) }
        let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
        end

        context "when zip_code workflow" do
          context "when voting enabled" do
            context "when not logged in" do
              it "redirects to the login page" do
                get :index
                expect(response).to redirect_to("/users/sign_in")
              end
            end

            context "when user data is not set" do
              before do
                sign_in user, scope: :user
              end

              it "redirects to the zip code" do
                get :index
                expect(response).to redirect_to(decidim_budgets.new_zip_code_path)
              end
            end

            context "when user data is set" do
              let!(:user_data) { create(:user_data, component: component, user: user, metadata: "12345") }

              before do
                sign_in user, scope: :user
              end

              it "renders index with booth layout" do
                get :index
                expect(response).to render_template(:index, layout: "decidim/budgets/voting_layout")
              end
            end
          end

          context "when voting is not enabled" do
            before do
              component.update(settings: { votes: "finished" })
            end

            it "does not render the layout" do
              get :index
              expect(response).to render_template(:index, layout: "layouts/decidim/participatory_process")
            end
          end
        end

        context "when not zip_code workflow" do
          before do
            component.update(settings: { workflow: "one" })
          end

          it "renders the index" do
            get :index
            expect(response).to render_template(:index, layout: "layouts/decidim/participatory_process")
          end
        end
      end
    end
  end
end
