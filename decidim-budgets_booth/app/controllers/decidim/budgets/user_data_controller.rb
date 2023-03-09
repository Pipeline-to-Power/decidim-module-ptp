# frozen_string_literal: true

module Decidim
  module Budgets
    class UserDataController < ApplicationController
      include FormFactory

      layout "decidim/budgets/voting_layout"
      def new
        @form = form(UserDataForm).instance
      end

      def create
        @form = form(UserDataForm).from_params(params.merge(user: current_user, component: current_component))
        CreateUserData.call(@form, zip_codes) do
          on(:ok) do
            flash[:notice] = I18n.t(".success", scope: "decidim.budgets.user_data")
            redirect_to budgets_path
          end

          on(:invalid) do |result|
            flash.now[:alert] = result || I18n.t("unknown", scope: "decidim.budgets.user_data.error")
            render action: "new"
          end
        end
      end

      private

      def zip_codes
        result = []
        budgets = Decidim::Budgets::Budget.where(
          component: current_component
        )

        projects_scopes = Decidim::Budgets::Project.where(budget: budgets).map(&:scope)
        projects_scopes.each do |scope|
          scope_zip = scope.code.split("_").last
          next if result.include?(scope_zip)

          result << scope_zip
        end
        result
      end
    end
  end
end
