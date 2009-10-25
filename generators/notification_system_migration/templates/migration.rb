class AddNotificationSystem < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string    :type
      
      t.string    :source_type
      t.integer   :source_id
      
      t.string    :data

      t.timestamps
    end
    
    create_table :notifications do |t|
      t.string    :type

      t.integer   :recipient_id
      t.integer   :event_id
      t.integer   :recurrence_id
      
      t.datetime  :date
      t.datetime  :sent_at
            
      t.timestamps      
    end
    
    create_table :notification_type_subscriptions do |t|
      t.integer   :subscriber_id
      t.string    :notification_type
      
      t.timestamps
    end
    
    create_table :recurrences do |t|
      t.integer   :interval
      t.datetime  :end_date
      
      t.timestamps
    end
    
    change_table :users do |t|
      t.string    :notification_types
    end
  end
  
  def self.down
    change_table :users do |t|
      t.remove    :notification_types
    end
    drop_table :recurrences
    drop_table :notifications
    drop_table :events
  end
end