# frozen_string_literal: true

module Decidim
  module Sms
    module Twilio
      # The data store for a Delivery status of messages being sent to the users
      class Delivery < Twilio::ApplicationRecord
      end
    end
  end
end
