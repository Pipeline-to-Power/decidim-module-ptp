# frozen_string_literal: true

module Decidim
  module Budgets
    class UserData < ApplicationRecord
      include Decidim::RecordEncryptor

      encrypt_attribute :metadata, type: :hash
      belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    end
  end
end
