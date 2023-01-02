# frozen_string_literal: true

module Decidim
  module Smsauth
    module Verification
      class AuthorizationsController < Decidim::Verifications::ApplicationController
        include Decidim::FormFactory
        include Decidim::Verifications::Renewable

        helper_method :authorization

        def new
          # We use the :update action here because this is also where the user
          # is redirected to in case they previously started the authorization
          # but did not finish it (i.e. the authorization is "pending").
          enforce_permission_to :update, :authorization, authorization: authorization

          @form = form(AuthorizationForm).instance
        end

        def create
          # We use the :update action here because this is also where the user
          # is redirected to in case they previously started the authorization
          # but did not finish it (i.e. the authorization is "pending").
          enforce_permission_to :update, :authorization, authorization: authorization

          @form = AuthorizationForm.from_params(params.merge(user: current_user))
          Decidim::Verifications::PerformAuthorizationStep.call(authorization, @form) do
            on(:ok) do
              update_attempt_session
              flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.sms")
              authorization_method = Decidim::Verifications::Adapter.from_element(authorization.name)
              redirect_to authorization_method.resume_authorization_path(redirect_url: redirect_url)
            end
            on(:invalid) do
              flash.now[:alert] = t("authorizations.create.error", scope: "decidim.verifications.sms")

              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :authorization, authorization: authorization

          @form = ConfirmationForm.new
          verification_code
        end

        def resend_code
          return unless eligible_to?

          @form = AuthorizationForm.from_params(params.merge(user: current_user).merge(authorization_params))

          Decidim::Verifications::PerformAuthorizationStep.call(authorization, @form) do
            on(:ok) do
              update_attempt_session
              flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.sms")
              authorization_method = Decidim::Verifications::Adapter.from_element(authorization.name)
              redirect_to authorization_method.resume_authorization_path(redirect_url: redirect_url)
            end
            on(:invalid) do
              flash.now[:alert] = I18n.t(".error", scope: "decidim.smsauth.omniauth.sms.authenticate_user")
              render :edit
            end
          end
        end

        def update
          enforce_permission_to :update, :authorization, authorization: authorization

          @form = ConfirmationForm.from_params(params)
          ::Decidim::Verifications::ConfirmUserAuthorization.call(authorization, @form, session) do
            on(:ok) do
              update_current_user!
              flash[:notice] = t("authorizations.update.success", scope: "decidim.verifications.sms")
              if redirect_url.blank?
                redirect_to decidim_verifications.authorizations_path
              else
                redirect_to stored_location_for(current_user)
              end
            end
            on(:invalid) do
              flash[:error] = t("update.incorrect", scope: "decidim.smsauth.verification.authorizations")
              redirect_to action: :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :authorization, authorization: authorization

          DestroyAuthorization.call(authorization) do
            on(:ok) do
              flash[:notice] = t("authorizations.destroy.success", scope: "decidim.verifications.sms")
              redirect_to action: :new
            end
          end
        end

        private

        def authorization
          @authorization ||= Decidim::Authorization.find_or_initialize_by(
            user: current_user,
            name: "smsauth_id"
          )
        end

        def attempt_session
          session[:last_attempt]
        end

        def update_attempt_session
          session[:last_attempt] = Time.current
        end

        def expired?
          attempt_session <= 1.minute.ago
        end

        def update_current_user!
          current_user.update(authorization_params)
        end

        def authorization_params
          {
            phone_number: authorization.metadata["phone_number"],
            phone_country: authorization.metadata["phone_country"]
          }
        end

        def verification_code
          @verification_code ||= authorization.verification_metadata["verification_code"]
        end

        def eligible_to?
          return true if expired?

          flash[:error] = I18n.t(".not_allowed", scope: "decidim.smsauth.omniauth.send_message")
          redirect_to action: :edit
          false
        end
      end
    end
  end
end
