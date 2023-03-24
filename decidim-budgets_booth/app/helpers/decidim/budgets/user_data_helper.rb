# frozen_string_literal: true

module Decidim
  module Budgets
    module UserDataHelper
      def voting_terms
        translated_attribute(component_settings.try(:voting_terms)).presence
      end
    end
  end
end
