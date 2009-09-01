class Notification < ActiveRecord::Base
  belongs_to :event, :class_name => 'CoolEvent'
  belongs_to :subscription, :class_name => 'EventTypeSubscription'
  
  def send_to_recipient
    raise "Should be implemented by base class"
  end
end