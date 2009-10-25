module NotificationSystem
  class Recurrence < ActiveRecord::Base
    validates_presence_of :interval
    validate :interval_is_at_least_zero
    
    private      
  
    def interval_is_at_least_zero
      return unless interval
      errors.add :interval, 'must be greater than zero' if interval < 0
    end          
  end
end