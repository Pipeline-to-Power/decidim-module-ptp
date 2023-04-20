# frozen_string_literal: true

require "spec_helper"

module Decidim
  module BudgetsBooth
    describe ProjectsControllerExtensions, type: :controller do
      routes { Decidim::Budgets::Engine.routes }
      controller(::Decidim::Budgets::ProjectsController) do
        include ProjectsControllerExtensions
      end

      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) do
        create(
          :budgets_component,
          settings: { workflow: "zip_code" }
        )
      end
      let!(:budgets) { create_list(:budget, 3, component: component) }
      let(:project) { create(:project, budget: budgets.last) }
      let(:vote) { "enabled" }
      let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
      let(:current_settings) { double(:current_settings, votes: vote) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        allow(component).to receive(:current_settings).and_return(current_settings)
      end

      describe "#index" do
        context "when zip_code workflow" do
          context "when voting enabled" do
            context "when not voted all budgets" do
              before do
                allow(controller).to receive(:voted_this?).and_return(false)
              end

              it "raises error" do
                expect do
                  get :index, params: { budget_id: budgets.last.id }
                end.to raise_error(ActionController::RoutingError, "Not Found")
              end
            end

            context "when voted that budget" do
              before do
                allow(controller).to receive(:voted_this?).and_return(true)
              end

              it "does not raise error" do
                get :index, params: { budget_id: budgets.last.id }
                expect(response).to render_template(:index)
              end
            end
          end

          context "when voting is disabled" do
            let!(:vote) { "disabled" }

            it "renders projects index" do
              get :index, params: { budget_id: budgets.last.id }
              expect(response).to render_template(:index)
            end
          end
        end

        context "when not zip code workflow" do
          before do
            component.update!(settings: { workflow: "one" })
          end

          it "renders the index template" do
            get :index, params: { budget_id: budgets.last.id }
            expect(response).to render_template(:index)
          end
        end
      end

      describe "#show" do
        context "when zip_code workflow" do
          context "when voting enabled" do
            context "when not voted that budget" do
              before do
                allow(controller).to receive(:voted_this?).and_return(false)
              end

              it "raises error" do
                expect do
                  get :show, params: { id: project.id, budget_id: budgets.last.id }
                end.to raise_error(ActionController::RoutingError, "Not Found")
              end
            end

            context "when voted that budget" do
              before do
                allow(controller).to receive(:voted_this?).and_return(true)
              end

              it "does not raise error" do
                get :show, params: { id: project.id, budget_id: budgets.last.id }
                expect(response).to render_template(:show)
              end
            end
          end

          context "when voting is disabled" do
            let!(:vote) { "disabled" }

            it "renders projects index" do
              get :show, params: { id: project.id, budget_id: budgets.last.id }
              expect(response).to render_template(:show)
            end
          end
        end

        context "when not zip code workflow" do
          before do
            component.update!(settings: { workflow: "one" })
          end

          it "renders the index template" do
            get :show, params: { id: project.id, budget_id: budgets.last.id }
            expect(response).to render_template(:show)
          end
        end
      end
    end
  end
end
