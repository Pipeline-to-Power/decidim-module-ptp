# frozen_string_literal: true

require "spec_helper"

describe "authorization process", type: :system do
  let!(:organization) { create(:organization, omniauth_settings: omniauth_settings, available_authorizations: available_authorizations) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let(:available_authorizations) { ["smsauth_id"] }
  let(:omniauth_settings) do
    {
      "omniauth_settings_sms_enabled" => true,
      "omniauth_settings_sms_icon" => ""
    }
  end

  include_context "with twilio gateway"

  before do
    switch_to_host(organization.host)
  end

  it "Adds the sms login method to authorization methods" do
    visit "/users/sign_in"
    expect(page).to have_content("Sign in with SMS")
    within ".register__separator" do
      expect(page).to have_content "Or"
    end
    expect(page).to have_content("Sign in with Email")
  end

  describe "Account section" do
    before do
      sign_in user, scope: :user
      visit decidim.account_path
    end

    it "shows the available authorizations" do
      within "#user-settings-tabs" do
        expect(page).to have_css("a", text: "Authorizations")
      end
      click_link "Authorization"
      expect(page).to have_content "Participant settings - Authorizations"
      within ".card--list__item" do
        expect(page).to have_css("svg.icon--lock-unlocked", count: 1)
      end
    end
  end

  describe "authorization" do
    before do
      sign_in user, scope: :user
      visit decidim.account_path
      click_link "Authorization"
      find(".card--list__item").click
    end

    it_behaves_like "phone authorization process"
  end

  context "when authorized" do
    before do
      user.update!(phone_number: "457788123", phone_country: "FI")
      sign_in user, scope: :user
      visit decidim.account_path
    end

    it "shows masked phone number" do
      expect(page).to have_field("Your phone number", disabled: true, with: "+358*****123")
    end
  end
end
