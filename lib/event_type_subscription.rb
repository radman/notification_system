class EventTypeSubscription < ActiveRecord::Base
  belongs_to :subscriber, :class_name => 'User'
  has_many :notifications

  named_scope :of_type, lambda { |event_class| 
    { :conditions => { :event_type => event_class.to_s } }
  }
  
end