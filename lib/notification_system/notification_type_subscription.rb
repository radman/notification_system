module NotificationSystem
  class NotificationTypeSubscription < ActiveRecord::Base
    belongs_to :subscriber, :class_name => 'User'
    belongs_to :recurrence, :class_name => 'NotificationSystem::Recurrence'
    
    # Replacing validates_presence_of :subscriber_id with custom validation, to debug #2416
    validates_presence_of :notification_type
    validate :check_that_subscriber_is_not_nil
    validate :notification_type_is_valid
    
    named_scope :recurrent, :conditions => 'recurrence_id IS NOT NULL'
            
    # something doesn't seem right about this; mainly that it's only used for recurrent subscriptions
    has_many :notifications, 
      :primary_key => 'notification_type', 
      :foreign_key => 'type', 
      :conditions => ['recipient_id = #{self.send(:subscriber_id)}'], # delay evaluation of #{} by putting it in single quotes
      :class_name => 'NotificationSystem::Notification'

    # UNTESTED (error handling is not well tested)
    def self.create_scheduled_notifications
      recurrent.each do |subscription|
        begin
          subscription.create_scheduled_notifications
        rescue Exception => exception
          NotificationSystem.report_exception(exception)
        end
      end
    end

    # UNTESTED (except via integration tests)
    def create_scheduled_notifications
      t = Time.now.utc
      x = self.notifications_created_since_recurrence_last_updated_count
            
      while (d = recurrence[x]) && t >= d
        create_notification_for_date(d)
        
        self.notifications_created_since_recurrence_last_updated_count += 1
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

    def check_that_subscriber_is_not_nil   
      if self.subscriber_id.nil?  
        self.logger.error "\x1B[41mA Subscription type was about to be created without a subscriber\x1B[0m" if self.logger
        self.errors.add :subscriber_id, "must be present"
      end
    end

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
