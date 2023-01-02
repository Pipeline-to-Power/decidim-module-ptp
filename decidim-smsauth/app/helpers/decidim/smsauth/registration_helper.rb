# frozen_string_literal: true

module Decidim
  module Smsauth
    # Custom helpers, scoped to the smsauth engine.
    #
    module RegistrationHelper
      def terms_page_path
        "/pages/terms-and-conditions"
      end

      def terms_and_conditions_page
        @terms_and_conditions_page ||= Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: current_organization)
      end
    end
  end
end
