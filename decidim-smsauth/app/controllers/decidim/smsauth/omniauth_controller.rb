# frozen_string_literal: true

module Decidim
  module Smsauth
    class OmniauthController < ::Decidim::Devise::OmniauthRegistrationsController
      # Make the view helpers available needed in the views

      # include Decidim::Sms::Twilio::TokenGenerator
      # include Decidim::NeedsPermission

      helper Decidim::Smsauth::Engine.routes.url_helpers
      helper Decidim::Smsauth::RegistrationHelper
      before_action :ensure_authorized, only: [:new, :registration, :user_registry]

      def new
        @form = form(OmniauthForm).instance
      end

      def edit
        @form = form(OmniauthForm).instance
      end

      def update
        @form = VerificationCodeForm.from_params(params)
        @verification_code = auth_session["verification_code"]

        VerifyMobilePhone.call(@form, auth_session) do
          on(:ok) do |_result|
            update_authorization!(current_user, auth_session)
            update_user!(current_user)
            reset_auth_session
            flash[:notice] = I18n.t(".updated_phone_number", scope: "decidim.smsauth.omniauth.authenticate_user")
            redirect_to decidim.account_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t(".error", scope: "decidim.smsauth.omniauth.authenticate_user")
            render action: "verification"
          end
        end
      end

      def send_message
        @form = ::Decidim::Smsauth::OmniauthForm.from_params(params)
        # in the test, and development environment, and with the Twilio gateway installation,
        # we have to set the organization to nil, since the delivery report can not be sent to the
        # localhost. However, we should set this to the current_organization if production
        ::Decidim::Smsauth::SendVerificationCode.call(@form, organization: set_organization) do
          on(:ok) do |result|
            generate_sessions!(result)
            flash[:notice] = I18n.t(".success", scope: "decidim.smsauth.omniauth.send_message", phone: formatted_phone_number(@form))
            redirect_to action: "verification"
          end

          on(:invalid) do |error_code|
            flash.now[:alert] = sms_sending_error(error_code)
            render action: "new"
          end
        end
      end

      def verification
        return redirect_to users_auth_sms_path if auth_session.blank?

        @form = form(VerificationCodeForm).instance
        @verification_code = auth_session["verification_code"]
      end

      def authenticate_user
        @form = VerificationCodeForm.from_params(authenticate_params)
        @verification_code = auth_session["verification_code"]

        VerifyMobilePhone.call(@form, auth_session) do
          on(:ok) do |result|
            update_sessions!(result)
            user = find_user!

            if user
              flash[:notice] = I18n.t(".signed_in", scope: "decidim.smsauth.omniauth.authenticate_user")
              sign_in_and_redirect(user)
            else
              flash[:notice] = I18n.t(".success", scope: "decidim.smsauth.omniauth.authenticate_user")
              redirect_to action: "registration"
            end
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t(".error", scope: "decidim.smsauth.omniauth.authenticate_user")
            render action: "verification"
          end
        end
      end

      def registration
        @form = form(UserRegistrationForm).instance
      end

      def user_registry
        @form = UserRegistrationForm.from_params(user_params.merge(current_locale: current_locale))
        RegisterByPhone.call(@form) do
          on(:ok) do |user|
            flash[:notice] = I18n.t(".success", scope: "decidim.smsauth.omniauth.registration")
            sign_in_and_redirect user, event: :authentication
          end
          on(:invalid) do
            flash.now[:alert] = I18n.t(".error", scope: "decidim.smsauth.omniauth.registration")
            render action: "registration"
          end
        end
      end

      def resend_code
        return unless ensure_resend_code

        params = params_from_previous_attempts

        @form = OmniauthForm.from_params(params)

        SendVerificationCode.call(@form, organization: set_organization) do
          on(:ok) do |result|
            update_sessions!(result)
            flash[:notice] = I18n.t(".resend", scope: "decidim.smsauth.omniauth.send_message", phone: formatted_phone_number(@form))
            redirect_to action: "verification"
          end

          on(:invalid) do |error_code|
            flash.now[:alert] = sms_sending_error(error_code)
            render action: "sms"
          end
        end
      end

      # This is overridden method from the Devise controller helpers
      # This is called when the user is successfully authenticated which means
      # that we also need to add the authorization for the user automatically
      # because a succesful sms authentication means the user has been
      # successfully authorized as well.
      def sign_in_and_redirect(resource_or_scope, *args)
        # Add authorization for the user
        return fail_authorize unless resource_or_scope.is_a?(::Decidim::User) &&
                                     authorize_user(resource_or_scope)

        reset_auth_session

        super
      end

      private

      def sms_sending_error(error_code)
        case error_code
        when :invalid_to_number
          I18n.t(".invalid_to_number", scope: "decidim.smsauth.omniauth.send_message.error")
        when :invalid_geo_permission
          I18n.t(".invalid_geo_permission", scope: "decidim.smsauth.omniauth.send_message.error")
        when :invalid_from_number
          I18n.t(".invalid_from_number", scope: "decidim.smsauth.omniauth.send_message.error")
        else
          I18n.t(".unknown", scope: "decidim.smsauth.omniauth.send_message.error")
        end
      end

      def authorize_user(user)
        authorize_user!(user)
      rescue Decidim::Smsauth::Authorization::AuthorizationBoundToOtherUserError
        nil
      end

      def authorize_user!(user)
        authorization = find_authorization(user)
        if authorization.user != user
          # The authorization method will recover from this error
          raise Authorization::AuthorizationBoundToOtherUserError
        end

        authorization.metadata = { phone_number: user.phone_number, phone_country: user.phone_country } if authorization.metadata.blank?
        authorization.unique_id = unique_id(user)

        authorization.save!

        # This will update the "granted_at" timestamp of the authorization
        # which will postpone expiration on re-authorizations in case the
        # authorization is set to expire (by default it will not expire).
        authorization.grant!

        authorization
      end

      def unique_id(user)
        Digest::MD5.hexdigest(
          "#{user.phone_country}-#{user.phone_number}-#{Rails.application.secrets.secret_key_base}"
        )
      end

      def formatted_phone_number(form)
        PhoneNumberFormatter.new(phone_number: form.phone_number, iso_country_code: form.phone_country).format
      end

      def reset_auth_session
        session&.delete(:authentication_attempt)
      end

      def generate_sessions!(result)
        session[:authentication_attempt] = {
          verification_code: result,
          sent_at: Time.current,
          country: @form.phone_country,
          phone: @form.phone_number,
          verified: false
        }
      end

      def update_sessions!(result)
        auth_session.merge!(verification_code: result, sent_at: Time.current)
      end

      def auth_session
        session[:authentication_attempt].transform_keys(&:to_s)
      end

      def set_organization
        return nil if Rails.env.test? || Rails.env.development?

        current_organization
      end

      def resend_code_allowed?
        auth_session.present? &&
          auth_session["sent_at"] < 1.minute.ago
      end

      def ensure_resend_code
        return true if resend_code_allowed?

        flash[:error] = I18n.t(".not_allowed", scope: "decidim.smsauth.omniauth.send_message")
        redirect_to action: "verification"
        false
      end

      def params_from_previous_attempts
        {
          phone_number: user_params[:phone_number],
          phone_country: user_params[:phone_country]
        }
      end

      def authenticate_params
        @authenticate_params ||= params.merge(
          {
            phone_number: auth_session["phone"],
            phone_country: auth_session["country"]
          }
        )
      end

      def default_params
        {
          organization: current_organization,
          phone_number: auth_session["phone"],
          phone_country: auth_session["country"]
        }
      end

      def ensure_authorized
        return true if current_user.blank?

        flash[:error] = I18n.t(".unauthorized", scope: "decidim.smsauth.omniauth.authenticate_user")
        redirect_to decidim.root_path
        false
      end

      def find_user!
        Decidim::User.find_by(
          phone_number: default_params[:phone_number],
          phone_country: default_params[:phone_country]
        )
      end

      def user_params
        @user_params ||= (params[:user] || {}).merge(default_params)
      end

      def update_authorization!(user, auth_session)
        return false if current_user.blank? || user.blank?

        authorization = find_authorization(user)

        return false if authorization.blank?

        authorization.update(
          metadata: {
            phone_number: auth_session["phone"],
            phone_country: auth_session["country"]
          },
          unique_id: unique_id(user)
        )
        authorization.grant!
        true
      end

      def find_authorization(user)
        Decidim::Authorization.find_or_initialize_by(
          user: user,
          name: "smsauth_id"
        )
      end

      def update_user!(user)
        return if user.blank?

        user.update!(
          phone_number: auth_session["phone"],
          phone_country: auth_session["country"]
        )
      end
    end
  end
end
