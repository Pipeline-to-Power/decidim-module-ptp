# frozen_string_literal: true

module Decidim
  module Devise
    module SessionsHelper
      def should_show?
        flash.alert.present? && flash.alert != t("decidim.budgets.voting.index.sign_in_first")
      end
    end
  end
end
