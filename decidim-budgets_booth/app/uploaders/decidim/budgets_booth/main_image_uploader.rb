# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # This class deals with uploading hero images to budgets.
    class MainImageUploader < RecordImageUploader
      set_variants do
        { default: { resize_to_fit: [700, 300] } }
      end
    end
  end
end
