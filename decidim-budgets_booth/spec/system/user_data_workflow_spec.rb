# frozen_string_literal: true

require "spec_helper"

describe "user data workflow", type: :system do
  include_context "with scoped budgets"
  let(:projects_count) { 4 }
  let(:decidim_budgets) { Decidim::EngineRouter.main_proxy(component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let(:organization) { component.organization }
  let(:first_budget) { budgets.first }

  before do
    switch_to_host(organization.host)
  end

  context "when not zip_code workflow" do
    before do
      visit decidim_budgets.new_zip_code_path
    end

    it_behaves_like "ensure zip code workflow"
  end

  context "when not signed in" do
    before do
      component.update(settings: { workflow: "zip_code" })
      visit decidim_budgets.new_zip_code_path
    end

    it_behaves_like "ensure user sign in"
  end

  context "when voted" do
    let!(:order) { create(:order, user: user, budget: first_budget) }
    let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "10004" }) }

    before do
      component.update(settings: { workflow: "zip_code" })
      order.projects << first_budget.projects.first
      order.projects << first_budget.projects.second
      order.projects << first_budget.projects.third
      order.checked_out_at = Time.current
      order.save!
      sign_in user, scope: :user
      visit decidim_budgets.new_zip_code_path
    end

    it "does not let adding zip code" do
      within_flash_messages do
        expect(page).to have_content("You can not change your ZIP code after started voting. Delete all of your votes first.")
      end
      expect(page).to have_current_path("/")
    end
  end

  context "when voting is not open" do
    let(:active_step_id) { component.participatory_space.active_step.id }

    before do
      component.update!(settings: { workflow: "zip_code" }, step_settings: { active_step_id => { votes: :finished } })
      sign_in user, scope: :user
      visit decidim_budgets.new_zip_code_path
    end

    it "does not let the user to add their zip code" do
      within_flash_messages do
        expect(page).to have_content("You can not set your ZIP code when the voting is not open.")
      end
      expect(page).to have_current_path("/")
    end
  end

  context "when before_actions met" do
    let(:non_existing_zip_code) { "12345" }
    let(:existing_zip_code) { "10004" }

    before do
      component.update!(settings: { workflow: "zip_code" })
      sign_in user, scope: :user
      visit decidim_budgets.new_zip_code_path
    end

    context "when default zip_code_length" do
      it_behaves_like "rendering new zip code page", 5
    end

    context "when zip_code_length is set" do
      before do
        allow(Decidim::BudgetsBooth.config).to receive(:zip_code_length).and_return(6)
        visit decidim_budgets.new_zip_code_path
      end

      it_behaves_like "rendering new zip code page", 6
    end

    context "when submitting the form" do
      context "when empty" do
        before do
          click_button "Find my ballots"
        end

        it "renders errors" do
          within ".zip-code" do
            expect(page).to have_content("ZIP code format is not correct.")
          end
          within "#affirm-checkbox" do
            expect(page).to have_content("must be accepted")
          end
          check "By checking this box, I affirm that these stamenets are true, and that I meet the voting eligibility requirements."
          click_button "Find my ballots"

          expect(page).to have_no_selector("#affirm-checkbox")
          expect(page).to have_no_content("must be accepted")

          fill_in_code(non_existing_zip_code, "digit")
          click_button "Find my ballots"
          within "#zip-code-not-valid" do
            expect(page).to have_content("The ZIP code you provided is not part of the areas that are eligible for voting.")
          end
        end
      end
    end

    describe "cancel button" do
      context "when no user data" do
        it "redirects to the root path" do
          expect(page).to have_button("Cancel")
          click_button "Cancel"
          expect(page).to have_content("Are you sure you want to exit?")
          click_link("OK")
          expect(page).to have_current_path("/")
        end
      end

      context "when user data exists" do
        let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "10004" }) }

        before do
          visit decidim_budgets.new_zip_code_path
        end

        it "redirects to the budgets path" do
          expect(page).to have_button("Cancel")
          click_button "Cancel"
          expect(page).to have_content("Are you sure you want to exit?")
          click_link("OK")
          expect(page).to have_current_path(decidim_budgets.budgets_path)
        end
      end
    end

    context "when submitting with correct data" do
      before do
        check "By checking this box, I affirm that these stamenets are true, and that I meet the voting eligibility requirements."
        fill_in_code(existing_zip_code, "digit")
        click_button "Find my ballots"
      end

      context "when user data does not exist" do
        it "creates user_data and redirects the user" do
          within_flash_messages do
            expect(page).to have_content("You have successfully registered your ZIP code.")
          end
          expect(page).to have_current_path(decidim_budgets.budgets_path)
          expect(user.budgets_user_data.last.metadata).to eq({ "zip_code" => existing_zip_code })
        end
      end
    end

    context "when userdata exists" do
      let!(:user_data) { create(:user_data, component: component, user: user, metadata: { zip_code: "quox" }) }

      before do
        check "By checking this box, I affirm that these stamenets are true, and that I meet the voting eligibility requirements."
        fill_in_code(existing_zip_code, "digit")
        click_button "Find my ballots"
      end

      it "updates existing metadata" do
        within_flash_messages do
          expect(page).to have_content("You have successfully registered your ZIP code.")
        end
        expect(page).to have_current_path(decidim_budgets.budgets_path)
        data = Decidim::Budgets::UserData.last
        expect(Decidim::Budgets::UserData.count).to eq(1)
        expect(data.metadata).to eq({ "zip_code" => "10004" })
      end
    end
  end

  describe "input fields" do
    context "when pasting" do
      before do
        component.update!(settings: { workflow: "zip_code" })
        sign_in user, scope: :user
        visit decidim_budgets.new_zip_code_path
        check "By checking this box, I affirm that these stamenets are true, and that I meet the voting eligibility requirements."
      end

      context "when not valid clipboard" do
        let(:clipboard_content_plain) { "a12_3" }

        it "renders error correctly" do
          page.execute_script(
            <<~JS
              var dt = new DataTransfer();
              dt.setData("text/plain", #{clipboard_content_plain.to_json});
              var element = document.querySelector('input[name="digit1"]');
              element.dispatchEvent(new ClipboardEvent("paste", { clipboardData: dt }));
            JS
          )
          within ".zip-code" do
            expect(page).to have_content("Only letters and digits are allowed.")
          end
          expect(page).to have_selector(".is-invalid-input", count: 5)
        end
      end

      context "when valid clipboard" do
        let(:clipboard_content_plain) { "abcd" }

        before do
          fill_in_code("1234", "digit")
        end

        it "pastes correctly" do
          page.execute_script(
            <<~JS
              var dt = new DataTransfer();
              dt.setData("text/plain", #{clipboard_content_plain.to_json});
              var element = document.querySelector('input[name="digit3"]');
              element.dispatchEvent(new ClipboardEvent("paste", { clipboardData: dt }));
            JS
          )
          within ".zip-code" do
            expect(page).to have_no_content("Only letters and digits are allowed.")
          end
          expect(page).to have_no_selector(".is-invalid-input")
          inputs = page.find_all('input[name^="digit"]')
          expect(inputs[0].value).to eq("1")
          expect(inputs[1].value).to eq("2")
          expect(inputs[2].value).to have_content("a")
          expect(inputs[3].value).to have_content("b")
          expect(inputs[4].value).to have_content("c")
        end
      end

      # context "key up" do
      #   it "deletes with backspace" do
      #     find('div[contenteditable="true"].ql-editor').native.send_keys "a", [:left], [:enter], [:shift, :enter], [:backspace], [:backspace]
      #   end

      #   it "adds the key" do

      #   end
      # end
    end
  end

  private

  def fill_in_code(code, element)
    code.length.times do |ind|
      break if code[ind].blank?

      fill_in "#{element}#{ind + 1}", with: code[ind]
    end
  end
end
