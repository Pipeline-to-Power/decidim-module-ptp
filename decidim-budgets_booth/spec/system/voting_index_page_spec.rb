# frozen_string_literal: true

require "spec_helper"

describe "Voting index page", type: :system do
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:organization) { component.organization }
  let(:component) { create(:budgets_component) }

  let(:budget) { create(:budget, component: component, total_budget: 100_000) }
  let!(:project1) { create(:project, budget: budget, budget_amount: 25_000) }
  let!(:project2) { create(:project, budget: budget, budget_amount: 50_000) }

  before do
    switch_to_host(organization.host)
  end

  context "when not voting" do
    before do
      visit decidim_budgets.budgets_path
    end

    it_behaves_like "non-voting view" do
      let!(:projects) { [project1, project2] }
    end

    it_behaves_like "filtering projects" do
      let!(:projects) { [project1, project2] }
      let(:current_component) { component }
    end
    it "explores the budgets" do
      expect(page).to have_content("Welcome to the vote!")
      expect(page).to have_content("Start voting")
      expect(page).not_to have_content("Back to budgets")
    end

    context "when ordering by highest cost" do
      it_behaves_like "ordering projects by selected option", "Highest cost" do
        let(:first_project) { project2 }
        let(:last_project) { project1 }
      end
    end

    context "when ordering by lowest cost" do
      it_behaves_like "ordering projects by selected option", "Lowest cost" do
        let(:first_project) { project1 }
        let(:last_project) { project2 }
      end
    end
  end

  context "when entering voting" do
    context "when use is not signed_in" do
      before do
        visit decidim_budgets.budget_voting_index_path(budget)
      end

      it "sends the user to the sign in page" do
        expect(page).to have_current_path "/users/sign_in"
        within_flash_messages do
          expect(page).to have_content "You need to sign in to start voting."
        end
        expect(page).to have_content("Sign in with SMS")
        expect(page).to have_content("Sign in with Email")
      end
    end

    context "when user is not  authorized" do
      context "when there is only one authorization option configured" do
        let(:voting_url) { decidim_budgets.budget_voting_index_path(budget) }
        let(:authorization_url) { "/authorizations/new?handler=dummy_authorization_handler&redirect_url=#{CGI.escape(voting_url)}" }

        include_context "with single permission"
        before do
          sign_in user
          visit decidim_budgets.budget_voting_index_path(budget)
        end

        it "asks the user to authorize before voting" do
          within_flash_messages do
            expect(page).to have_content "You need to verify your phone number with SMS in order to vote."
          end
          expect(page).to have_current_path(authorization_url)
        end
      end

      context "when multiple authorizations are configured" do
        let(:available_authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
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

        before do
          component.organization.update!(available_authorizations: available_authorizations)
          component.update!(permissions: permissions)

          sign_in user
          visit decidim_budgets.budget_voting_index_path(budget)
        end

        it "displays the authorization options" do
          expect(page).to have_content("You need to verify yourself in order to vote.")
          expect(page).to have_content("Example authorization")
          expect(page).to have_content("Another example authorization")
          expect(page).not_to have_content("You are now in the voting booth.")
          expect(page).to have_current_path(decidim_budgets.budget_voting_index_path(budget))
        end
      end
    end

    context "when authorized" do
      include_context "with single permission"
      let!(:authorization) { create(:authorization, :granted, user: user, name: "dummy_authorization_handler", unique_id: "123456789X") }

      before do
        sign_in user
        visit decidim_budgets.budget_voting_index_path(budget)
      end

      it "enters the voting booth" do
        expect(page).to have_content("You are now in the voting booth.")
        expect(page).to have_current_path(decidim_budgets.budget_voting_index_path(budget))
      end
    end
  end
end
