# frozen_string_literal: true

RSpec.shared_examples "phone verification process" do
  include_context "with twilio gateway"

  describe "authentication process" do
    it "does the authentication process" do
      find("span", text: "Lithuania (+370)").click
      within ".ss-list" do
        find("div", text: /Finland/).select_option
      end
      fill_in "Phone number", with: "45887874"
      click_button "Send code via SMS"
      within_flash_messages do
        expect(page).to have_content(/Verification code sent to/)
      end
      expect(page).to have_content("Enter verification code")
      click_link("Resend code")
      within_flash_messages do
        expect(page).to have_content("Please wait at least 1 minute to resend the code.")
      end
      allow(Time).to receive(:current).and_return(Time.current + 2.minutes)
      click_link("Resend code")
      expect(page).to have_content(/Verification code resent to/)
      fill_in "Verification code", with: "000000"
      click_button "Verify"
      within_flash_messages do
        expect(page).to have_content("Verification failed. Please try again.")
      end
      code = page.find("#hint").text
      fill_in "Verification code", with: code
      click_button "Verify"
      expect(page).not_to have_current_path decidim_smsauth.users_auth_sms_edit_path
      within_flash_messages do
        expect(page).not_to have_content("Verification failed. Please try again.")
      end
    end
  end
end
