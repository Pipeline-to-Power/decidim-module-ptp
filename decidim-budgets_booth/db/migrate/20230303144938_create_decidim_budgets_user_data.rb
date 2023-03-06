# frozen_string_literal: true

class CreateDecidimBudgetsUserData < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_budgets_user_data do |t|
      t.jsonb :metadata
      t.references :decidim_component, null: false, indec: true
      t.references :decidim_user, null: false, index: true
      t.timestamps

      t.index []
    end

    add_index :decidim_budgets_user_data, [:decidim_component_id, :decidim_user_id], unique: true, name: "decidim_budgets_user_data_unique_user_and_component"
  end
end
