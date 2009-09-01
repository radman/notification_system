class Notification < ActiveRecord::Base
  belongs_to :event
  belongs_to :event_type_subscription
  
  def send
    raise "Should be implemented by base class"
  end
end