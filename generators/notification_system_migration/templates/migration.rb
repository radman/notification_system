class AddNotificationSystem < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :type, :source_type, :data
      t.integer :source_id
      t.timestamps
    end
    
    create_table :notifications do |t|
      t.integer :recipient_id, :event_id
      t.datetime :date, :sent_at
      t.string :type
      t.timestamps
    end
    
    change_table :users do |t|
      t.string :notification_types
    end
  end
  
  def self.down
    drop_table :notifications
    drop_table :event_type_subscriptions
    drop_table :cool_events
  end
end