# frozen_string_literal: true

module Decidim
  module Budgets
    class UserDataController < ApplicationController
      include FormFactory
      include ::Decidim::BudgetsBooth::VotingExtensions

      delegate :user_zip_code, to: :current_workflow

      layout "decidim/budgets/voting_layout"
      before_action :ensure_voting_booth_forced
      before_action :ensure_authenticated
      before_action :ensure_voting_open
      before_action :ensure_not_voted

      helper_method :user_zip_code

      def new
        @form = form(UserDataForm).instance
        @form.zip_code = user_zip_code
      end

      def create
        @invalid = false
        @form = form(UserDataForm).from_params(params.merge(user: current_user, component: current_component))
        CreateUserData.call(@form, all_zip_codes) do
          on(:ok) do
            flash[:notice] = I18n.t("success", scope: "decidim.budgets.user_data")
            redirect_to decidim_budgets.budgets_path
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
        return if voting_open?

        flash[:warning] = t("voting_ended", scope: "decidim.budgets.user_data.new")
        redirect_to decidim.root_path
      end

      def all_zip_codes
        @all_zip_codes ||= scope_manager.zip_codes_for(current_component)
      end

      def budgets
        @budgets ||= Decidim::Budgets::Budget.where(component: current_component)
      end

      def scope_manager
        @scope_manager ||= ::Decidim::BudgetsBooth::ScopeManager.new(current_component)
      end

      def invalidate_form
        @invalid = true
      end
    end
  end
end
