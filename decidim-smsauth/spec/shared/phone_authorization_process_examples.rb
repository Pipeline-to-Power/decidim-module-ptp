# frozen_string_literal: true

RSpec.shared_examples "phone authorization process" do
  include_context "with twilio gateway"

  describe "authentication process" do
    it "does the authentication process" do
      find("span", text: "Lithuania (+370)").click
      within ".ss-list" do
        find("div", text: /Finland/).select_option
      end
      fill_in "Phone number", with: "45887874"
      click_button "Send code via SMS"
      expect(Decidim::Authorization.where(user: user).count).to eq(1)
      within_flash_messages do
        expect(page).to have_content(/Thanks! We've sent an SMS to your phone./)
      end
      expect(page).to have_content("Introduce the verification code you received")
      click_link("Resend code")
      within_flash_messages do
        expect(page).to have_content("Please wait at least 1 minute to resend the code.")
      end
      allow(Time).to receive(:current).and_return(Time.current + 2.minutes)
      click_link("Resend code")
      expect(page).to have_content(/Thanks! We've sent an SMS to your phone./)
      fill_in "Verification code", with: "000000"
      click_button "Verify"
      within_flash_messages do
        expect(page).to have_content("Verification failed. Please try again.")
      end
      fill_in "Verification code", with: "1234567"
      click_button "Verify"
      expect(page).to have_current_path decidim_verifications.authorizations_path
      within ".card--list__item" do
        expect(page).to have_css("svg.icon--lock-locked", count: 1)
      end
      expect(Decidim::Authorization.where(user: user).count).to eq(1)
      expect(Decidim::Authorization.find_by(user: user).granted_at).not_to be_nil
    end

    # context "with previously registed phone number" do
    #   let!(:another_user) { create(:user, :confirmed, organizaion: organizaion, phone_number: )}
    # end
  end
end
