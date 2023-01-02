# frozen_string_literal: true

module Decidim
  module Budgets
    class VotingController < ProjectsController
      include Decidim::Budgets::NeedsCurrentOrder
      include Decidim::UserProfile

      layout :determine_layout
      before_action :store_user_location!, if: :storable_location?
      # The callback which stores the current location must be added before you authenticate the user
      # as `authenticate_user!` (or whatever your resource is) will halt the filter chain and redirect
      # before the location can be stored.

      before_action :authenticate_user!
      before_action :ensure_voting_open!
      before_action :ensure_authorized!, if: :authorization_required?
      before_action :ensure_not_voted!, only: [:index]

      def index
        enforce_permission_to :vote, :project, project: budget.projects.first, budget: budget, workflow: current_workflow
        @select_project = set_selected_project
        unset_select_params
      end

      def confirm; end

      def user_has_no_permission
        flash[:alert] = if current_user
                          t(".not_permitted_to")
                        else
                          t(".sign_in_first")
                        end
        redirect_to(user_has_no_permission_referer || user_has_no_permission_path)
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

      def user_has_no_permission_path
        return decidim_budgets.budget_projects_path(budget) if user_signed_in?

        super
      end

      def store_user_location!
        # :user is the scope we are authenticating
        store_location_for(:user, request.fullpath)
      end

      def ensure_voting_open!
        return if voting_open?

        flash[:warning] = I18n.t("decidim.budgets.voting.general.not_open_warning")
        redirect_to decidim_budgets.budget_projects_path(budget)
      end

      def ensure_authorized!
        return if user_authorized?

        if authorization_options.one?
          # If the authorization option is one, it is sms authorization, since
          # this authorization should be selected if configured.
          flash[:warning] = I18n.t("decidim.budgets.voting.general.not_authorized")
          authorization_method = Decidim::Verifications::Adapter.from_element(authorization_options.first)
          redirect_to authorization_method.root_path(redirect_url: decidim_budgets.budget_voting_index_path(budget))
        else
          flash[:warning] = I18n.t("decidim.budgets.voting.general.multi_authorization_warning")
          @auth_options = authorization_methods

          render :auth_methods
        end
      end

      def ensure_not_voted!
        redirect_to decidim_budgets.confirm_budget_voting_index_path(budget) if current_order.checked_out?
      end

      def authorization_required?
        @authorization_required ||= authorization_options&.present?
      end

      def authorization_options
        permission = current_component.permissions&.fetch("vote", nil)
        permission&.fetch("authorization_handlers", nil)&.keys
      end

      # This ensures that only people eligible to vote can enter the voting
      #  after the authorization step. The authorization conditions
      # should be used to control user's ability to vote (e.g. where they live,
      # how old they are, etc.).
      def user_authorized?
        @user_authorized ||= user_signed_in? && action_authorized_to("vote").ok?
      end

      def authorization_methods
        @authorization_methods ||= available_verification_workflows.select do |handler|
          authorization_options.include?(handler.key)
        end
      end

      def set_selected_project
        return if params[:select_project].blank?

        project = budget&.projects&.find(params[:select_project])
        return unless project && projects.exclude?(project)

        project
      end

      def unset_select_params
        params[:select_project] = nil
      end

      def decidim_budgets
        @decidim_budgets ||= Decidim::EngineRouter.main_proxy(current_component)
      end

      def determine_layout
        return nil if @auth_options.present?

        "decidim/budgets/voting_layout"
      end
    end
  end
end
