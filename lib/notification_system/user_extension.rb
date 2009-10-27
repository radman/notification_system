module NotificationSystem
  module UserExtension
    def self.included(base)
      base.class_eval do
        has_many  :notification_type_subscriptions, 
                  :class_name => 'NotificationSystem::NotificationTypeSubscription', 
                  :foreign_key => 'subscriber_id'
      end
    end
    
    def wants_notification?(notification)
      notification.recipient == self && (!notification.class.subscribable? || is_subscribed_to_notification_type?(notification.type))
    end
    
    def is_subscribed_to_notification_type?(notification_type)
      notification_type_subscriptions.exists?(:notification_type => notification_type)
    end
  end
end