# frozen_string_literal: true

require "spec_helper"

describe "authentication with phone number", type: :system do
  let(:organization) { create(:organization) }

  include_context "with twilio gateway"

  before do
    switch_to_host(organization.host)
    visit_smsauth
  end

  it_behaves_like "phone verification process"
  describe "log-in with SMS" do
    let(:phone) { 4_551_122_334 }

    before do
      find("span", text: "Lithuania (+370)").click
      within ".ss-list" do
        find("div", text: /Finland/).select_option
      end
      fill_in "Phone number", with: phone
      click_button "Send code via SMS"
      code = page.find("#hint").text
      fill_in "Verification code", with: code
    end

    context "when authorized phone number before" do
      let(:phone_country) { "FI" }
      let!(:user) { create(:user, organization: organization, phone_number: phone, phone_country: phone_country) }

      it "authenticate and redirects the user" do
        click_button "Verify"
        expect(page).to have_current_path decidim_verifications.authorizations_path
      end
    end

    context "when new user" do
      before do
        click_button "Verify"
      end

      context "when no email" do
        it "leads the user to account creation process" do
          expect(page).to have_current_path decidim_smsauth.users_auth_sms_registration_path
          within_flash_messages do
            expect(page).to have_content("Phone number successfully verified.")
          end
          fill_in "Your name", with: "Dummy name"
          click_button "Sign up"
          click_button "Check and continue"
          within_flash_messages do
            expect(page).to have_content("An error occured, please try again")
          end
          check "I agree to the Terms of Service"
          click_button "Sign up"
          expect(page).to have_current_path decidim_verifications.authorizations_path
          within_flash_messages do
            expect(page).to have_content("You have successfully registered and authorized")
          end
          expect(Decidim::User.count).to be(1)
          user = Decidim::User.last
          expect(user.phone_number).to eq("4551122334")
          expect(user.phone_country).to eq("FI")
          expect(user.email).to match(/^smsauth-.+@\d+\.lvh\.me$/)
          expect(Decidim::Authorization.where(user: user).count).to eq(1)
        end
      end

      context "when provide email addrss" do
        let!(:user) { create(:user, organization: organization, email: "someone@test.net") }

        it "checks its uniqueness" do
          fill_in "Your name", with: "Dummy name"
          fill_in "Your email", with: "someone@test.net"
          check "I agree to the Terms of Service"
          click_button "Sign up"
          click_button "Check and continue"
          within_flash_messages do
            expect(page).to have_content("An error occured, please try again")
          end
          expect(page).to have_content(/has already been taken/)
          fill_in "Your email", with: "another_email@nowhere.net"
          click_button "Sign up"
          expect(page).to have_current_path decidim_verifications.authorizations_path
          within_flash_messages do
            expect(page).to have_content("You have successfully registered and authorized")
          end
        end
      end
    end
  end
end
