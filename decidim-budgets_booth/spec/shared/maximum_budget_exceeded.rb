# frozen_string_literal: true

shared_examples "maximum budget exceed" do
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
