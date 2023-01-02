# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe VotingController, type: :controller do
      routes { Decidim::Budgets::Engine.routes }

      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:params) { { budget_id: budget.id } }
      let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "#index" do
        let(:component) { create(:budgets_component) }
        let!(:project) { create(:project, budget: budget, component: component, budget_amount: 70_000) }
        let(:budget) { create(:budget, component: component, total_budget: 100_000) }

        context "with not logged in" do
          it "redirects unauthorized" do
            get :index, params: params
            expect(flash[:alert]).to be_present
            expect(response).to redirect_to("/users/sign_in")
          end
        end

        context "with permission not exist" do
          before do
            sign_in user, scope: :user
          end

          it "renders the voting page" do
            get :index, params: params
            expect(flash[:alert]).to be_nil
            expect(response.status).to eq(200)
          end
        end

        context "when permission exits" do
          let(:action) do
            { scope: :user, action: :vote, subject: project }
          end
          let!(:permission_action) { Decidim::PermissionAction.new(action) }

          before do
            sign_in user, scope: :user
          end

          context "when not voted yet" do
            it "permits the user" do
              get :index, params: params
              expect(flash[:alert]).to be_nil
              expect(subject).to render_template(layout: "decidim/budgets/voting_layout")
              expect(subject).to render_template(:index)
            end
          end

          context "when already voted" do
            let(:projects) do
              build_list(:project, 2, budget_amount: 35_000, budget: budget)
            end
            let!(:order) do
              order = create(:order,
                             user: user,
                             budget: budget)
              order.projects << projects
              order.checked_out_at = Time.current
              order.save!
            end

            it "redirects the user to projects" do
              get :index, params: params
              expect(flash[:alert]).to be_nil
              expect(subject).to redirect_to(decidim_budgets.confirm_budget_voting_index_path(budget))
            end
          end
        end

        context "when authorization is required" do
          let(:permissions) do
            {
              vote: {
                authorization_handlers: {
                  "dummy_authorization_handler" => {}
                }
              }
            }
          end
          let(:available_authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
          let(:voting_url) { decidim_budgets.budget_voting_index_path(budget) }
          let(:authorization_url) { "/authorizations/new?handler=dummy_authorization_handler&redirect_url=#{CGI.escape(voting_url)}" }

          before do
            component.organization.update!(available_authorizations: available_authorizations)
            component.update!(permissions: permissions)
            sign_in user, scope: :user
          end

          context "when the user is authorized with the configured authorization" do
            let!(:authorization) { create(:authorization, :granted, user: user, name: "dummy_authorization_handler", unique_id: "123456789X") }

            it "lets the user to vote" do
              get :index, params: params
              expect(subject).to render_template(layout: "decidim/budgets/voting_layout")
              expect(subject).to render_template(:index)
            end

            context "and the authorization is not granted" do
              let!(:authorization) { create(:authorization, :pending, user: user, name: "dummy_authorization_handler", unique_id: "123456789X") }

              it "redirects the user to authorize themselves" do
                get :index, params: params
                expect(subject).to redirect_to authorization_url
              end
            end
          end

          context "when the user is authorized with unallowed authorization" do
            let!(:authorization) { create(:authorization, :granted, metadata: { postal_code: "123456" }, name: "another_dummy_authorization_handler") }

            it "redirects the user to authorize themselves" do
              get :index, params: params
              expect(subject).to redirect_to authorization_url
            end
          end

          context "when the user is not authorized" do
            it "redirects the user to authorize themselves" do
              get :index, params: params
              expect(subject).to redirect_to authorization_url
            end
          end

          context "when there are multiple authorizations configured" do
            let(:permissions) do
              {
                vote: {
                  authorization_handlers: {
                    "dummy_authorization_handler" => {},
                    "another_dummy_authorization_handler" => {}
                  }
                }
              }
            end

            context "when the user is not authorized" do
              it "renders the authorization options page" do
                get :index, params: params
                expect(subject).to render_template(:auth_methods)
              end
            end
          end
        end
      end
    end
  end
end
