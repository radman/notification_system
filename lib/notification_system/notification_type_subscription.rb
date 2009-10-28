module NotificationSystem
  class NotificationTypeSubscription < ActiveRecord::Base
    belongs_to :subscriber, :class_name => 'User'
    belongs_to :recurrence, :class_name => 'NotificationSystem::Recurrence'
        
    validates_presence_of :subscriber, :notification_type
    validate :notification_type_is_valid
    
    # TODO: test this method, and decide what it should really allow
    def notification_type=(notification_type)
      super(notification_type.to_s)
    end
        
    # something doesn't seem right about this; mainly that it's only used for recurrent subscriptions
    has_many :notifications, 
      :primary_key => 'notification_type', 
      :foreign_key => 'type', 
      :conditions => ['recipient_id = #{self.send(:subscriber_id)}'], # delay evaluation of #{} by putting it in single quotes
      :class_name => 'NotificationSystem::Notification'

    # UNTESTED    
    def self.create_scheduled_notifications
      all.each do |subscription|
        subscription.create_scheduled_notifications
      end
    end

    # UNTESTED (except via integration tests)    
    def create_scheduled_notifications
      return unless recurrence
      
      t = Time.now.utc # NOTE: this conversion might not be necessary (we're not dealing with sql)
      x = notifications.created_after(recurrence.updated_at).count

      while (d = recurrence[x]) && t >= d
        create_notification_for_date(d)
        x += 1
      end
    end

    # UNTESTED (but should be a private method anyway)    
    def create_notification_for_date(date)
      notification_type.constantize.create! :recipient => subscriber, :date => date      
    end
    
    ###########################################
        
    private
    
    def notification_type_is_valid
      errors.add :notification_type, 'must reference a subclass of Notification' unless references_notification_type?(notification_type)
    end
    
    def references_notification_type?(str)
      return false if str.blank?
      
      begin
        defined?(str.camelize.constantize) && 
        str.constantize.superclass == Notification
      rescue NameError
        return false
      end
    end    
  end
end