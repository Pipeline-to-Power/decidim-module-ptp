# frozen_string_literal: true

class CreateDecidimBudgetsUserData < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_budgets_user_data do |t|
      t.integer :decidim_component_id
      t.integer :decidim_user_id
      t.jsonb :metadata
      t.timestamps
    end

    add_index :decidim_budgets_user_data, :decidim_component_id
    add_index :decidim_budgets_user_data, :decidim_user_id
    add_foreign_key :decidim_budgets_user_data, :decidim_components
    add_foreign_key :decidim_budgets_user_data, :decidim_users
  end
end
