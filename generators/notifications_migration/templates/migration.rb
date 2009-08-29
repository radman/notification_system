class AddNotifications < ActiveRecord::Migration
  def self.up
    create_table :cool_events do |t|
      t.string :type, :source_type
      t.integer :source_id, :subscriber_id
      t.timestamps
    end

    change_table :users do |t|
      t.text :cool_event_subscriptions, :cool_email_subscriptions
    end    
  end
  
  def self.down
    change_table :users do |t|
      t.remove :cool_event_subscriptions
      t.remove :cool_email_subscriptions
    end

    drop_table :cool_events
  end
end