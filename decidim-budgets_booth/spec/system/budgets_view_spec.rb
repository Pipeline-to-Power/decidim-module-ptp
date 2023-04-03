# frozen_string_literal: true

require "spec_helper"

describe "Budgets view", type: :system do
  include_context "with scoped budgets"
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:organization) { component.organization }

  context "when not zip_code workflow" do
    before do
      switch_to_host(organization.host)
    end

    context "when not signed in" do
      before { visit decidim_budgets.budgets_path }

      it "redirects the user" do
        expect(page).to have_link(translated(budgets.first.title), href: decidim_budgets.budget_path(budgets.first))
        expect(page).to have_selector("a", text: /show/i, count: 3)
        expect(page).to have_content("€100,000")
      end
    end

    context "when workflow" do
      include_context "with zip_code workflow"

      context "when no user" do
        before { visit decidim_budgets.budgets_path }

        it "redirects user to the login page" do
          expect(page).to have_current_path(decidim.new_user_session_path)
          within_flash_messages do
            expect(page).to have_content "You need to login first."
          end
        end
      end

      context "when signed in" do
        before { sign_in user, scope: :user }

        context "when no zip code" do
          before { visit decidim_budgets.budgets_path }

          it "redirects user to zipcode entering path" do
            expect(page).to have_current_path(decidim_budgets.new_zip_code_path)
            within_flash_messages do
              expect(page).to have_content "You need to enter your zip code first."
            end
          end
        end

        context "when user zip_code presents" do
          let!(:user_data) { create(:user_data, component: component, user: user, metadata: "dummy_1234") }

          context "when no budgets were found" do
            before { visit decidim_budgets.budgets_path }

            it "renders budgets page" do
              expect(page).to have_current_path(decidim_budgets.budgets_path)
              expect(page).to have_content "No budgets were found based on your zip code. You can change your zip code if it's not correct, or you can search again later."
            end
          end

          context "when some budgets to vote on" do
            before do
              user_data.update!(metadata: "1004")
              visit decidim_budgets.budgets_path
            end

            it "renders the budgets page and budgets" do
              expect(page).to have_current_path(decidim_budgets.budgets_path)
              expect(page).to have_content "You are now in the voting booth."
              expect(page).to have_content "lkfsdjl"
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
end
