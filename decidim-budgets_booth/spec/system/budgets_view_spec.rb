# frozen_string_literal: true

require "spec_helper"

describe "Budgets view", type: :system do
  include_context "with scoped budgets"

  let(:projects_count) { 1 }
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when not signed in" do
    before { visit decidim_budgets.budgets_path }

    it "shows the normal layout" do
      expect(page).to have_link(translated(budgets.first.title), href: decidim_budgets.budget_path(budgets.first))
      expect(page).to have_selector("a", text: /show/i, count: 3)
      expect(page).to have_content("€100,000")
    end
  end

  context "when workflow" do
    include_context "with zip_code workflow"

    context "when not signed in" do
      before { visit decidim_budgets.budgets_path }

      it_behaves_like "ensure user sign in"
    end

    context "when signed in" do
      before { sign_in user, scope: :user }

      context "when no zip code" do
        before { visit decidim_budgets.budgets_path }

        it "redirects user to zipcode entering path" do
          expect(page).to have_current_path(decidim_budgets.new_zip_code_path)
        end
      end

      context "with user zip_code exist" do
        let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "dummy_1234" }) }

        context "when no budgets to vote" do
          before { visit decidim_budgets.budgets_path }

          it "renders budgets page" do
            expect(page).to have_current_path(decidim_budgets.budgets_path)
            expect(page).to have_content "No budgets were found based on your ZIP code. You can change your ZIP code if it's not correct, or you can search again later."
          end
        end

        context "when budgets to vote" do
          let(:first_budget) { budgets.first }
          let(:second_budget) { budgets.second }
          let(:landing_page_content) { Decidim::Faker::Localized.sentence(word_count: 5) }

          before do
            user_data.update!(metadata: { zip_code: "10004" })
            visit decidim_budgets.budgets_path
          end

          it "renders the budgets page and budgets" do
            expect(page).to have_current_path(decidim_budgets.budgets_path)
            expect(page).to have_content "You are now in the voting booth."
            within "#budgets" do
              expect(page).to have_css(".card.card--list.budget-list", count: 2)
              expect(page).to have_selector("a", text: "More info", count: 2)
              expect(page).to have_link(text: /TAKE PART/, href: decidim_budgets.budget_voting_index_path(first_budget))
              expect(page).to have_link(text: /TAKE PART/, href: decidim_budgets.budget_voting_index_path(second_budget))
              expect(page).to have_link(translated(first_budget.title), href: decidim_budgets.budget_voting_index_path(budgets.first))
              expect(page).to have_link(translated(second_budget.title), href: decidim_budgets.budget_voting_index_path(second_budget))
              expect(page).to have_content("Eius officiis expedita. 55")
              expect(page).to have_content("Eius officiis expedita. 56")
            end
            expect(page).to have_no_css(".callout.warning.font-customizer")
            expect(page).to have_button("Cancel voting")
            click_button "Cancel voting"
            within ".small.reveal.confirm-reveal" do
              expect(page).to have_content("Are you sure you want to exit the voting booth?")
              click_link "OK"
            end
            expect(page).to have_link(href: "/")
          end

          context "when description is long" do
            before do
              first_budget.update!(description: { en: "<p>Lorem ipsum dolor sit amet, <em>consectetur</em> adipiscing elit. <b>Fus</b>. ultricies lacus vel dui vestibulum, eu aliquam libero convallis. Donec vitae ligula velit</p" })
              second_budget.update!(description: { en: "<p>Fooba ligul dolor sit amet, <em>consectetur</em> adipiscing elit. <b>Fus</b>. ultricies lacus vel dui vestibulum, eu aliquam libero convallis. Donec vitae ligula velit</p" })
              visit decidim_budgets.budgets_path
            end

            it "truncates the budgets description" do
              within "#budgets" do
                expect(page).to have_content("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fus. ult...")
                expect(page).to have_content("Fooba ligul dolor sit amet, consectetur adipiscing elit. Fus. ult...")
              end
            end
          end

          context "with landing page content" do
            let(:landing_page_content) { Decidim::Faker::Localized.sentence(word_count: 5) }

            before do
              component.update(settings: component_settings.merge(workflow: "zip_code", landing_page_content: landing_page_content))
              visit current_path
            end

            it "renders callout message" do
              expect(page).to have_css(".callout.warning.font-customizer")
              within ".callout.warning.font-customizer" do
                expect(page).to have_content(translated(landing_page_content))
              end
            end
          end

          context "with cancel voting booth url" do
            before do
              stub_request(:get, "http://www.example.com/foo")
                .to_return(status: 200, body: "Dummy body")
              component.update(settings: component_settings.merge(workflow: "zip_code", vote_cancel_url: "http://www.example.com/foo"))
              visit current_path
            end

            it "redirects to correct url" do
              expect(page).to have_button("Cancel voting")
              click_button "Cancel voting"
              within ".small.reveal.confirm-reveal" do
                expect(page).to have_content("Are you sure you want to exit the voting booth?")
                click_link "OK"
              end
              expect(page).to have_current_path("http://www.example.com/foo")
            end
          end

          describe "vote all budgets" do
            # We add another budget to the list of budgets where use is eligible to vote
            let!(:extra_budget) { create(:budget, component: component, scope: extra_scope, total_budget: 100_000) }
            let!(:extra_scope) { create(:scope, parent: parent_scope, organization: organization) }
            let!(:extra_postal) { create(:scope, name: { en: "10004" }, code: "EXTRA_10004", parent: extra_scope, organization: organization) }
            let!(:extra_project) { create(:project, budget: extra_budget, budget_amount: 75_000) }

            before do
              Decidim::BudgetsBooth::ScopeManager.clear_cache!
              component.update(settings: component_settings.merge(workflow: "zip_code", vote_threshold_percent: 0))
            end

            context "when maximum_budgets_to_vote_on not set" do
              before do
                [extra_budget, first_budget, second_budget].each do |bdg|
                  create_order(bdg)
                end
                visit current_path
              end

              it "shows all of the budgets after completing voting" do
                expect(page).to have_selector("div.card.card--list.budget-list", count: 3)
              end
            end

            context "when maximum_budgets_to_vote_on is set" do
              before do
                component.update(settings: component_settings.merge(workflow: "zip_code", vote_threshold_percent: 0, maximum_budgets_to_vote_on: 2))
                [extra_budget, first_budget].each do |bdg|
                  create_order(bdg)
                end
                visit current_path
              end

              it "shows only voted budgets" do
                expect(page).to have_selector("div.card.card--list.budget-list", count: 2)
              end
            end
          end
        end
      end
    end
  end

  private

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end

  def budget_path(budget)
    decidim_budgets.budget_path(budget.id)
  end

  def create_order(budget)
    order = create(:order, user: user, budget: budget)
    order.projects << budget.projects.first
    order.checked_out_at = Time.current
    order.save!
  end
end
