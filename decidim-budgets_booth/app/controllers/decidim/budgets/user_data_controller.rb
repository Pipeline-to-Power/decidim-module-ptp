# frozen_string_literal: true

module Decidim
  module Budgets
    class UserDataController < ApplicationController
      include FormFactory
      include ::Decidim::BudgetsBooth::ScopeManager
      include ::Decidim::BudgetsBooth::BudgetsControllerHelper

      layout "decidim/budgets/voting_layout"
      before_action :ensure_zip_code_workflow
      before_action :ensure_authenticated
      before_action :ensure_not_voted

      def new
        @form = form(UserDataForm).instance
      end

      def create
        postals = zip_codes(Decidim::Budgets::Project.where(budget: budgets))
        @form = form(UserDataForm).from_params(params.merge(user: current_user, component: current_component))
        CreateUserData.call(@form, postals) do
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

      def budgets
        @budgets ||= Decidim::Budgets::Budget.where(component: current_component)
      end
    end
  end
end
