class CoolEventSubscription < ActiveRecord::Base
  named_scope :of_type, lambda { |cool_event_class| 
    { :conditions => { :cool_event_type => cool_event_class.to_s } }
  }
  
  belongs_to :subscriber, :class_name => 'User'
  
end