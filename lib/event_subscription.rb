class EventSubscription < ActiveRecord::Base
  named_scope :of_type, lambda { |event_class| 
    { :conditions => { :event_type => event_class.to_s } }
  }
  
  belongs_to :subscriber, :class_name => 'User'
  
end