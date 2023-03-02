# frozen_string_literal: true

class AddMainImageToDecidimBudgetsBudgets < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_budgets_budgets, :main_image, :string
  end
end
