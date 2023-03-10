# frozen_string_literal: true

module Decidim
  module Budgets
    module UserDataHelper
      def city_name
        translated_attribute(component_settings.try(:city_name)).presence
      end
    end
  end
end
