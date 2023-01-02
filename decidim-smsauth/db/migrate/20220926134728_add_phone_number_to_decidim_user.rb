# frozen_string_literal: true

class AddPhoneNumberToDecidimUser < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_users, :phone_number, :string
    add_column :decidim_users, :phone_country, :string
  end
end
