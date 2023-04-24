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

        let(:user) { create(:user, :confirmed, organization: organization) }
        let(:organization) { create(:organization) }
        let(:component) { create(:budgets_component, settings: component_settings, organization: organization) }
        let(:component_settings_base) { { scopes_enabled: true, scope_id: parent_scope.id } }
        let(:component_settings) { component_settings_base.merge(workflow: "zip_code", votes: "enabled") }
        let(:parent_scope) { create(:scope, organization: organization) }
        let!(:subscopes) do
          [].tap do |scopes|
            scopes << create(:scope, name: { en: "123456" }, parent: parent_scope, organization: organization)
            scopes << create(:scope, name: { en: "789012" }, parent: parent_scope, organization: organization)
            scopes << create(:scope, name: { en: "345678" }, parent: parent_scope, organization: organization)
          end
        end
        let!(:budgets) do
          [].tap do |list|
            list << create(:budget, component: component, scope: subscopes[0])
            list << create(:budget, component: component, scope: subscopes[1])
            list << create(:budget, component: component, scope: subscopes[2])
          end
        end
        let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }

        before do
          request.env["decidim.current_organization"] = organization
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
              let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "123456" }) }

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
              component.update(settings: component_settings_base.merge(votes: "finished"))
            end

            it "does not render the layout" do
              get :index
              expect(response).to render_template(:index, layout: "layouts/decidim/participatory_process")
            end
          end
        end

        context "when not zip_code workflow" do
          before do
            component.update(settings: component_settings_base.merge(workflow: "one"))
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
