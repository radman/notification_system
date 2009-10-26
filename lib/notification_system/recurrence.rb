module NotificationSystem
  # A recurrence represents a set of fixed times (and thus requires a start date as a point of reference)
  class Recurrence < ActiveRecord::Base
    validates_presence_of :interval, :starts_at
    validate :interval_is_at_least_zero
       
    def [](index)
      return nil if index < 0
      (occurs_at = starts_at + index * interval) > ends_at ? nil : occurs_at
    end
    
    private      
  
    def interval_is_at_least_zero
      return unless interval
      errors.add :interval, 'must be greater than zero' if interval < 0
    end          
  end
end