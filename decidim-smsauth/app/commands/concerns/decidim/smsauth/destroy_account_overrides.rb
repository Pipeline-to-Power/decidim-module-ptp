# frozen_string_literal: true

module Decidim
  module Smsauth
    module DestroyAccountOverrides
      extend ActiveSupport::Concern
      included do
        private

        def destroy_user_account!
          @user.invalidate_all_sessions!

          @user.name = ""
          @user.nickname = ""
          @user.email = ""
          @user.phone_number = ""
          @user.phone_country = ""
          @user.delete_reason = @form.delete_reason
          @user.admin = false if @user.admin?
          @user.deleted_at = Time.current
          @user.skip_reconfirmation!
          @user.avatar.purge
          @user.save!
        end
      end
    end
  end
end
