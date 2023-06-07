# frozen_string_literal: true

module Decidim
  module Budgets
    class VotingController < ProjectsController
      include Decidim::Budgets::NeedsCurrentOrder
      include ::Decidim::BudgetsBooth::VotingSupport

      layout "decidim/budgets/voting_layout"
      before_action :store_user_location!, if: :storable_location?
      # The callback which stores the current location must be added before you authenticate the user
      # as `authenticate_user!` (or whatever your resource is) will halt the filter chain and redirect
      # before the location can be stored.

      before_action :ensure_voting_open!
      before_action :ensure_authenticated
      before_action :ensure_not_voted_this!

      def index
        enforce_permission_to :vote, :project, project: budget.projects.first, budget: budget, workflow: current_workflow
      end

      private

      delegate :voted?, to: :current_workflow

      # Its important that the location is NOT stored if:
      # - The request method is not GET (non idempotent)
      # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
      #    infinite redirect loop.
      # - The request is an Ajax request as this can lead to very unexpected behaviour.
      def storable_location?
        request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
      end

      def store_user_location!
        # :user is the scope we are authenticating
        store_location_for(:user, request.fullpath)
      end

      def ensure_voting_open!
        return if voting_open?

        flash[:warning] = I18n.t("not_open_warning", scope: "decidim.budgets.voting.general")
        redirect_to decidim_budgets.budget_projects_path(budget)
      end

      def ensure_not_voted_this!
        return unless current_order.checked_out?

        flash[:warning] = I18n.t("not_allowed", scope: "decidim.budgets.budgets.index")
        redirect_to decidim.root_path
      end

      def decidim_budgets
        @decidim_budgets ||= Decidim::EngineRouter.main_proxy(current_component)
      end
    end
  end
end
