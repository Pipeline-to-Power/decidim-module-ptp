# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module BudgetsBooth
    module BudgetExtensions
      extend ActiveSupport::Concern
      include Decidim::HasUploadValidations

      included do
        has_one_attached :main_image
        validates_upload :main_image, uploader: Decidim::BudgetsBooth::MainImageUploader
      end
    end
  end
end
