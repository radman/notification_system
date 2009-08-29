class AddNotifications < ActiveRecord::Migration
  def self.up
    create_table :cool_events do |t|
      t.string :type, :source_type
      t.integer :source_id, :subscriber_id
      t.timestamps
    end
    
    create_table :cool_event_subscriptions do |t|
      t.integer :subscriber_id
      t.string :cool_event_type
      t.boolean :wants_emails, :default => true
    end
  end
  
  def self.down
    drop_table :cool_event_subscriptions
    drop_table :cool_events
  end
end