# frozen_string_literal: true

module Decidim
  module Budgets
    class CreateUserData < Decidim::Command
      def initialize(form, zip_codes)
        @zip_codes = zip_codes
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        return broadcast(:invalid, user_data_error) if user_data_exist?

        return broadcast(:invalid, zip_code_not_exit) unless zip_code_included?

        create_user_data!

        broadcast(:ok)
      end

      private

      attr_reader :form, :budget, :zip_codes

      def create_user_data!
        attributes = {
          component: form.component,
          user: form.user,
          metadata: form.metadata,
          affirm_statements_are_correct: form.affirm_statements_are_correct
        }
        @user_data = Decidim.traceability.create!(
          UserData,
          form.user,
          attributes,
          visibility: "all"
        )
      end

      def user_data_exist?
        Decidim::Budgets::UserData.where(
          user: form.user,
          component: form.component
        ).any?
      end

      def user_data_error
        I18n.t("registered_zip_code", scope: "decidim.budgets.user_data.error")
      end

      def zip_code_included?
        zip_codes.include?(form.metadata)
      end

      def zip_code_not_exit
        I18n.t("zip_code_included", scope: "decidim.budgets.user_data.error")
      end
    end
  end
end
