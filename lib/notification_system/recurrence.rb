module NotificationSystem
  # A recurrence represents a set of fixed times (and thus requires a start date as a point of reference)
  class Recurrence < ActiveRecord::Base
    has_one :notification_type_subscription # untested

    validates_presence_of :interval, :starts_at
    validate :interval_is_at_least_zero
       
    def [](index)
      return nil if index < 0

      offset = ((updated_at - starts_at) / interval).ceil

      if ends_at.nil?
        starts_at + (index + offset) * interval
      else
        occurs_at = starts_at + (index + offset) * interval 
        occurs_at > ends_at ? nil : occurs_at
      end
    end
    
    protected
    
    # UNTESTED
    def after_update
      return unless self.notification_type_subscription
      self.notification_type_subscription.reload
      self.notification_type_subscription.update_attributes!(:notifications_created_since_recurrence_last_updated_count => 0)
    end
    
    private      
  
    def interval_is_at_least_zero
      return unless interval
      errors.add :interval, 'must be greater than zero' if interval < 0
    end          
  end
end