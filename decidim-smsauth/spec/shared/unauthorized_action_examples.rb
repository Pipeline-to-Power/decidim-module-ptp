# frozen_string_literal: true

RSpec.shared_examples "unauthorized action" do |action|
  let(:decidim) { Decidim::Core::Engine.routes.url_helpers }

  it "redirects user with proper errors" do
    get action
    expect(subject).to redirect_to(decidim.root_path)
    expect(flash[:error]).to have_content("You are not authorized to perform this action.")
  end
end
