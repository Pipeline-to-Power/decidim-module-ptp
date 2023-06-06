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

        return broadcast(:invalid, zip_code_not_exit) unless zip_code_included?

        create_user_data!

        broadcast(:ok)
      end

      private

      attr_reader :form, :budget, :zip_codes

      def create_user_data!
        attributes = {
          metadata: { zip_code: form.zip_code },
          affirm_statements_are_correct: form.affirm_statements_are_correct
        }
        @user_data = Decidim::Budgets::UserData.find_or_create_by!(
          user: form.user,
          component: form.component
        )

        Decidim.traceability.update!(
          @user_data,
          form.user,
          attributes,
          visibility: "all"
        )
      end

      def zip_code_included?
        zip_codes.include?(form.zip_code)
      end

      def zip_code_not_exit
        I18n.t("zip_code_included", scope: "decidim.budgets.user_data.error")
      end
    end
  end
end
