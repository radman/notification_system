module NotificationSystem
  class NotificationTypeSubscription < ActiveRecord::Base
    belongs_to :subscriber, :class_name => 'User'
    
    validates_presence_of :subscriber, :notification_type
    validate :notification_type_is_valid
    
    # TODO: test this method, and decide what it should really allow
    def notification_type=(notification_type)
      super(notification_type.to_s)
    end
    
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