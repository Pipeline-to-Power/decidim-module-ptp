# frozen_string_literal: true

shared_examples "ensure user data" do
  it "redirects the user" do
    expect(page).to have_current_path("/")
    within_flash_messages do
      expect(page).to have_content "You are not authorized to perform this action"
    end
  end
end
