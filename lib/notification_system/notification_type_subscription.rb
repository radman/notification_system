module NotificationSystem
  class NotificationTypeSubscription < ActiveRecord::Base
    belongs_to :subscriber, :class_name => 'User'
    belongs_to :recurrence, :class_name => 'NotificationSystem::Recurrence'
        
    validates_presence_of :subscriber, :notification_type
    validate :notification_type_is_valid
    
    named_scope :recurrent, :conditions => 'recurrence_id IS NOT NULL'
            
    # something doesn't seem right about this; mainly that it's only used for recurrent subscriptions
    has_many :notifications, 
      :primary_key => 'notification_type', 
      :foreign_key => 'type', 
      :conditions => ['recipient_id = #{self.send(:subscriber_id)}'], # delay evaluation of #{} by putting it in single quotes
      :class_name => 'NotificationSystem::Notification'

    def self.create_scheduled_notifications
      recurrent.each do |subscription|
        subscription.create_scheduled_notifications
      end
    end

    # UNTESTED (except via integration tests)    
    def create_scheduled_notifications
      t = Time.now.utc
      x = self.notifications_created_since_recurrence_last_updated_count
            
      while (d = recurrence[x]) && t >= d
        create_notification_for_date(d)
        
        self.notifications_created_since_recurrence_last_updated_count += 1
        # self.notifications_created_since_recurrence_last_updated_count = y
        self.save!
        
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