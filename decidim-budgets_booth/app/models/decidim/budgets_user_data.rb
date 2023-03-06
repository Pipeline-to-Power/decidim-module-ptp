# frozen_string_literal: true

module Decidim
  class BudgetsUserData < ApplicationRecord
    include Decidim::RecordEncryptor

    belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component", optional: true
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    encrypt_attribute :metadata, type: :hash
  end
end