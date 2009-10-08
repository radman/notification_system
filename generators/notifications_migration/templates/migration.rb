class AddCoolNotifications < ActiveRecord::Migration
  def self.up
    create_table :cool_events do |t|
      t.string :type, :source_type
      t.integer :source_id
      t.timestamps
    end
    
    create_table :event_type_subscriptions do |t|
      t.integer :subscriber_id
      t.string :event_type
      t.boolean :includes_emails, :default => true
      t.timestamps
    end
    
    create_table :notifications do |t|
      t.string :type
      t.integer :event_id, :subscription_id
      
      t.datetime :start_date, :end_date
      t.integer :interval, :times_sent, :default => 0
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :notifications
    drop_table :event_type_subscriptions
    drop_table :cool_events
  end
end