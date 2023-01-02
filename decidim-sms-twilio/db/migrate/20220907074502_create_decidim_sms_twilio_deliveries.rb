# frozen_string_literal: true

class CreateDecidimSmsTwilioDeliveries < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_sms_twilio_deliveries do |t|
      t.string :from
      t.string :to
      t.string :body
      t.string :sid
      t.string :status

      t.timestamps
    end
  end
end
