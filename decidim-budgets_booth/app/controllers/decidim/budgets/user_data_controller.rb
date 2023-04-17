# frozen_string_literal: true

module Decidim
  module Budgets
    class UserDataController < ApplicationController
      include FormFactory
      include ::Decidim::BudgetsBooth::BudgetsControllerHelper

      delegate :zip_codes, :user_zip_code, to: :scope_manager

      layout "decidim/budgets/voting_layout"
      before_action :ensure_voting_booth_forced
      before_action :ensure_authenticated
      before_action :ensure_voting_open
      before_action :ensure_not_voted

      def new
        @form = form(UserDataForm).instance
        @form.zip_code = user_zip_code(current_user, current_component)
      end

      def create
        @invalid = false
        @form = form(UserDataForm).from_params(params.merge(user: current_user, component: current_component))
        CreateUserData.call(@form, all_zip_codes) do
          on(:ok) do
            flash[:notice] = I18n.t("success", scope: "decidim.budgets.user_data")
            redirect_to budgets_path
          end

          on(:invalid) do |result|
            invalidate_form if result.present?
            flash.now[:alert] = I18n.t("unknown", scope: "decidim.budgets.user_data.error")
            render action: "new"
          end
        end
      end

      private

      def ensure_voting_open
        return true if voting_open?

        flash[:warning] = t("voting_ended", scope: "decidim.budgets.user_data.new")
        redirect_to decidim.root_path
      end

      def all_zip_codes
        [].tap do |zip_code|
          budgets.each do |budget|
            zip_code << zip_codes(budget)
          end
        end.flatten.uniq
      end

      def budgets
        @budgets ||= Decidim::Budgets::Budget.where(component: current_component)
      end

      def scope_manager
        @scope_manager ||= ::Decidim::BudgetsBooth::ScopeManager.new
      end

      def invalidate_form
        @invalid = true
      end
    end
  end
end
