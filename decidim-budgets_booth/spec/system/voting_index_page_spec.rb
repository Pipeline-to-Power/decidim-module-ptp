# frozen_string_literal: true

require "spec_helper"

describe "Voting index page", type: :system do
  include_context "with scoped budgets"

  let(:projects_count) { 10 }
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:first_budget) { budgets.first }
  let(:second_budget) { budgets.second }
  let(:active_step_id) { component.participatory_space.active_step.id }

  before do
    switch_to_host(organization.host)
  end

  context "when not signed in" do
    before do
      component.update(settings: component_settings.merge(workflow: "zip_code"))
      visit_budget(first_budget)
    end

    it_behaves_like "ensure user sign in"
  end

  context "when no user_data" do
    before do
      component.update(settings: component_settings.merge(workflow: "zip_code"))
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it_behaves_like "ensure user data"
  end

  context "when not allowed to vote that budget" do
    let!(:user_data) { create(:user_data, component: component, user: user) }

    before do
      component.update(settings: component_settings.merge(workflow: "zip_code"))
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it_behaves_like "not allowable voting"
  end

  context "when voted to that budget" do
    let!(:user_data) { create(:user_data, component: component, user: user) }
    let!(:order) { create(:order, :with_projects, user: user, budget: first_budget) }

    before do
      component.update(settings: component_settings.merge(workflow: "zip_code"))
      order.update!(checked_out_at: Time.current)
      user_data.update!(metadata: { zip_code: "10004" })
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it "redirects the user" do
      expect(page).to have_current_path("/")
      within_flash_messages do
        expect(page).to have_content "You are not allowed to perform this action."
      end
    end
  end

  describe "voting" do
    let!(:user_data) { create(:user_data, component: component, user: user) }

    before do
      component.update(settings: component_settings.merge(workflow: "zip_code", projects_per_page: 5))
      user_data.update!(metadata: { zip_code: "10004" })
      sign_in user, scope: :user
      visit_budget(first_budget)
    end

    it_behaves_like "cancel voting"

    it "renders the page correctly" do
      expect(page).to have_content("You are now in the voting booth.")
      expect(page).to have_content("You decide the #{first_budget.title["en"]} budget")
      expect(page).to have_button("Cancel voting")
      expect(page).to have_content("TOTAL BUDGET €100,000")
      expect(page).to have_content("10 PROJECTS")
      expect(page).to have_selector("button", text: "Read more", count: 5)
      expect(page).to have_selector("button", text: "Add to your vote", count: 5)
    end

    describe "budget summary" do
      before do
        click_button "Add to your vote", match: :first
      end

      it "updates budget summary" do
        within ".budget-summary__total" do
          expect(page).to have_content("TOTAL BUDGET €100,000")
        end
        expect(page).to have_content("ASSIGNED: €25,000")
        within "#order-selected-projects" do
          expect(page).to have_content "1 project selected"
        end
        within ".progress.budget-progress" do
          expect(page).to have_css(".progress-meter-text.progress-meter-text--right", match: :first, text: "25%")
        end
        within page.all(".budget-list .budget-list__item")[1] do
          click_button "Read more"
        end
        within ".reveal-overlay" do
          click_button "Add to your vote"
        end
        page.find(".close-button").click
        expect(page).to have_content("ASSIGNED: €50,000")
        within "#order-selected-projects" do
          expect(page).to have_content "2 projects selected"
        end
        within ".progress.budget-progress" do
          expect(page).to have_css(".progress-meter-text.progress-meter-text--right", match: :first, text: "50%")
        end
        click_link "2"
        click_button "Add to your vote", match: :first
        expect(page).to have_content("ASSIGNED: €75,000")
        within "#order-selected-projects" do
          expect(page).to have_content "3 projects selected"
        end

        within page.all(".budget-list .budget-list__item")[0] do
          click_button "Read more"
        end
        within ".reveal-overlay" do
          click_button "Remove from vote"
        end
        expect(page).to have_content("ASSIGNED: €50,000")
        within "#order-selected-projects" do
          expect(page).to have_content "2 projects selected"
        end
      end
    end

    it "paginates the projects" do
      expect(page).to have_css(".budget-list .budget-list__item", count: 5)
      find("li.page", text: "2").click
      expect(page).to have_css(".budget-list .budget-list__item", count: 5)
    end

    it "adds and removes projects" do
      expect(page).to have_button("Add to your vote", count: 5)
      click_button("Add to your vote", match: :first)
      expect(page).to have_button("Add to your vote", count: 4)
      expect(page).to have_button("Remove from vote", count: 1)

      within page.all(".budget-list .budget-list__item")[0] do
        header = page.all("button")[0].text
        click_button "Read more"
        expect(page).to have_content(header)
        expect(page).to have_button("Remove from vote")
      end
      within ".reveal-overlay" do
        click_button "Remove from vote"
        expect(page).to have_button("Add to your vote", count: 1)
      end
    end

    describe "filtering projects" do
      let!(:categories) { create_list(:category, 3, participatory_space: component.participatory_space) }
      let(:current_projects) { first_budget.projects }

      it "allows searching by text" do
        project = current_projects.first
        within ".filters__search" do
          fill_in "filter[search_text_cont]", with: translated(project.title)

          find(".button").click
        end

        within "#projects" do
          expect(page).to have_css(".budget-list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      it "allows filtering by scope" do
        project = current_projects.first
        project.scope = first_budget.scope
        project.save
        visit current_path

        within ".filters__section.with_any_scope_check_boxes_tree_filter" do
          uncheck "All"
          check translated(first_budget.scope.name)
        end

        within "#projects" do
          expect(page).to have_css(".budget-list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      it "allows filtering by category" do
        project = current_projects.first
        category = categories.first
        project.category = category
        project.save

        visit current_path
        within ".filters__section.with_any_category_check_boxes_tree_filter" do
          uncheck "All"
          check translated(category.name)
        end

        within "#projects" do
          expect(page).to have_css(".budget-list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end
    end

    describe "#vote_success_content" do
      before do
        first_budget.update!(total_budget: 26_000)
      end

      context "when vote_success_content is not set" do
        before do
          visit current_path
          vote_budget!
        end

        it "does not show the success message by default" do
          expect(page).to have_no_selector("#thanks-message")
          expect(page).to have_current_path(decidim_budgets.budgets_path)
        end
      end

      context "when vote success is set" do
        before do
          component.update!(settings: component_settings.merge(workflow: "zip_code", vote_success_content: { en: "<p>Some dummy text</p>" }))
          visit current_path
          vote_budget!
        end

        it "shows the success message set" do
          expect(page).to have_selector("#thanks-message")
          within "#thanks-message" do
            expect(page).to have_content("Thank you for voting!")
            expect(page).to have_selector("p", text: "Some dummy text")
          end
          expect(page).to have_current_path(decidim_budgets.budgets_path)
        end
      end
    end

    describe "vote_complete_content" do
      let!(:order) { create(:order, user: user, budget: second_budget) }

      before do
        first_budget.update!(total_budget: 26_000)
        second_budget.update!(total_budget: 26_000)
        order.checked_out_at = Time.current
        order.projects << second_budget.projects.first
        order.save!
      end

      context "when not set" do
        before do
          visit current_path
          vote_budget!
        end

        it "does not show the modal" do
          expect(page).to have_no_selector("#vote-completed")
          expect(page).to have_current_path(decidim_budgets.budgets_path)
        end
      end

      context "when was set" do
        before do
          component.update!(settings: component_settings.merge(workflow: "zip_code", vote_completed_content: { en: "<p>Completed voting dummy text</p>" }))
          visit current_path
          vote_budget!
        end

        it "shows the modal" do
          expect(page).to have_selector("#vote-completed")
          within "#vote-completed" do
            expect(page).to have_content("You successfully completed your votes")
            expect(page).to have_content("Completed voting dummy text")
          end
          expect(page).to have_current_path(decidim_budgets.budgets_path)
        end
      end
    end

    describe "redirect after completing votes" do
      let!(:order) { create(:order, user: user, budget: second_budget) }

      before do
        first_budget.update!(total_budget: 26_000)
        second_budget.update!(total_budget: 26_000)
        order.checked_out_at = Time.current
        order.projects << second_budget.projects.first
        order.save!
      end

      context "when vote success URL is not set" do
        before do
          visit current_path
          vote_budget!
        end

        it "redirects to the budgets path" do
          expect(page).to have_current_path(decidim_budgets.budgets_path)
        end
      end

      context "when vote success URL is set" do
        include_context "with a survey"
        before do
          component.update!(settings: component_settings.merge(workflow: "zip_code", vote_completed_content: { en: "<p>Completed voting dummy text</p>" }, vote_success_url: main_component_path(surveys_component)))
          visit current_path
          vote_budget!
        end

        it "shows the modal" do
          expect(page).to have_current_path(main_component_path(surveys_component))
          expect(page).to have_selector("#vote-completed")
          within "#vote-completed" do
            expect(page).to have_content("You successfully completed your votes")
            expect(page).to have_content("Completed voting dummy text")
          end
        end
      end

      context "when non-zipcode workflow" do
        let!(:second_order) { create(:order, user: user, budget: budgets.last) }
        let(:third_budget) { budgets.last }

        include_context "with a survey"
        before do
          third_budget.update!(total_budget: 26_000)
          second_order.checked_out_at = Time.current
          second_order.projects << third_budget.projects.first
          second_order.save!
          component.update!(settings: component_settings.merge(workflow: "all", vote_completed_content: { en: "<p>Completed voting dummy text</p>" }, vote_success_url: main_component_path(surveys_component)))
          visit current_path
          non_zipcode_vote_budget!
        end

        it "shows the modal" do
          expect(page).to have_current_path(main_component_path(surveys_component))
          expect(page).to have_selector("#vote-completed")
          within "#vote-completed" do
            expect(page).to have_content("You successfully completed your votes")
            expect(page).to have_content("Completed voting dummy text")
          end
        end
      end
    end

    context "when maximum budget exceeds" do
      before do
        first_budget.update!(total_budget: 24_999)
        visit current_path
      end

      it "popups maximum error notice" do
        click_button "Add to your vote", match: :first
        expect(page).to have_content("Maximum budget exceeded")
        click_button "OK"
        within all(".budget-list .budget-list__item")[0] do
          click_button "Read more"
        end
        within ".reveal-overlay" do
          click_button "Add to your vote"
        end
        expect(page).to have_content("Maximum budget exceeded")
      end
    end

    context "when highest cost" do
      before { first_budget.projects.second.update!(budget_amount: 30_000) }

      it_behaves_like "ordering projects by selected option", "Highest cost" do
        let(:first_project) { first_budget.projects.second }
      end
    end

    context "when lowest cost" do
      before { first_budget.projects.second.update!(budget_amount: 20_000) }

      it_behaves_like "ordering projects by selected option", "Lowest cost" do
        let(:first_project) { first_budget.projects.second }
      end
    end

    context "when casting vote" do
      before do
        first_budget.update!(total_budget: 26_000)
        visit current_path
        click_button("Add to your vote", match: :first)
        click_button "Vote"
      end

      it "renders the info" do
        within "#budget-confirm" do
          expect(page).to have_content("These are the projects you have chosen to be part of the budget.")
          expect(page).to have_selector("li", text: "€25,000", count: 1)
          expect(page).to have_button("Confirm")
          expect(page).to have_button("Cancel")
          click_button("Cancel")
        end
        expect(page).to have_current_path(decidim_budgets.budget_voting_index_path(first_budget))
      end
    end

    describe "#show_full_description_on_listing_page" do
      let(:projects_count) { 1 }
      let(:project) { first_budget.projects.first }

      before do
        project.update!(description: Decidim::Faker::Localized.sentence(word_count: 20))
      end

      context "when not set" do
        before do
          visit current_path
        end

        it "does not shows complete description by default" do
          within("#project-#{project.id}-item") do
            expect(page).to have_selector("button", text: translated(project.title))
            expect(page).to have_button("Read more")
            expect(page).to have_content(/.*\.{3}$/)
          end
        end
      end

      context "when set" do
        before do
          component.update!(settings: component_settings.merge(workflow: "zip_code", show_full_description_on_listing_page: true))
          visit current_path
        end

        it "does not shows complete description by default" do
          within("#project-#{project.id}-item") do
            expect(page).to have_no_selector("button", text: translated(project.title))
            expect(page).to have_no_button("Read more")
            expect(page).to have_no_content(/.*\.{3}$/)
            expect(page).to have_content(translated(project.description))
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

  def visit_budget(budget)
    visit decidim_budgets.budget_voting_index_path(budget)
  end

  def vote_budget!
    click_button("Add to your vote", match: :first)
    click_button "Vote"
    click_button "Confirm"
  end

  def non_zipcode_vote_budget!
    click_button("Add to your vote", match: :first)
    click_button "I understand how to vote"
    click_button "I am ready"
    click_button "Confirm"
  end
end
