# frozen_string_literal: true

module Decidim
  module Smsauth
    module Verification
      class DestroyAuthorization < Rectify::Command
        # Public: Initializes the command.
        #
        # authorization - An Authorization object.
        def initialize(authorization)
          @authorization = authorization
        end

        def call
          destroy_authorization!
          broadcast(:ok)
        end

        private

        attr_reader :authorization

        def destroy_authorization!
          authorization.destroy!
        end
      end
    end
  end
end
