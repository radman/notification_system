module NotificationSystem
  module UserExtension
    def self.included(base)
      base.class_eval do
        has_many  :notification_type_subscriptions, 
                  :class_name => 'NotificationSystem::NotificationTypeSubscription', 
                  :foreign_key => 'subscriber_id'
        
        after_update :update_recurrent_subscriptions, :if => :timezone_changed?     
      end
    end
    
    def wants_notification?(notification)
      notification.recipient == self && (!notification.class.subscribable? || is_subscribed_to_notification_type?(notification.type))
    end

    def is_subscribed_to_notification_type?(notification_type)
      notification_type_subscriptions.exists?(:notification_type => notification_type.to_s)
    end

    # Example Params:
    # --- !map:HashWithIndifferentAccess 
    # CoachingSessionRescheduledNotification: !map:HashWithIndifferentAccess 
    #   is_subscribed: "true"
    # NewCommentOnYourArticleNotification: !map:HashWithIndifferentAccess 
    #   is_subscribed: "true"
    # ClientActivityNotification: !map:HashWithIndifferentAccess 
    #   is_subscribed: "true"
    #   recurrence: !map:HashWithIndifferentAccess 
    #     starts_at: Tue Oct 27 08:38:05 UTC 2009
    #     ends_at: Tue Oct 27 09:08:05 UTC 2009
    #     interval: "120"
    
    # TODO: UNTESTED (because i still can't test subscribable_types)
    # validations also need to be tested (e.g. on recurrences)
    # HARD: typed values should be saved somehow (or invalid values should be disallowed by design (i.e. dont use textboxes))
    def notification_types=(params)
      NotificationSystem::Notification.subscribable_types.each do |subscribable_type|
        type_params = params[subscribable_type.to_s]
        recurrence_params = type_params && type_params[:recurrence]
        
        if type_params && type_params[:is_subscribed] == "true"
          # create subscription if one does not exist
          unless self.is_subscribed_to_notification_type?(subscribable_type)
            self.notification_type_subscriptions << NotificationTypeSubscription.new(:notification_type => subscribable_type.to_s)
          end
        
          if recurrence_params && recurrence_params[:starts_at] && recurrence_params[:interval]
            subscription = self.notification_type_subscriptions.find_by_notification_type(subscribable_type.to_s)            
            
            recurrence_params[:starts_at] = ActiveSupport::TimeZone[timezone].parse(recurrence_params[:starts_at])
            
            if subscription.recurrence
              subscription.recurrence.update_attributes(recurrence_params)
            else
              subscription.update_attributes(:recurrence => NotificationSystem::Recurrence.create(recurrence_params))
            end
          end
        else
          # delete subscription if one exists
          if self.is_subscribed_to_notification_type?(subscribable_type)
            self.notification_type_subscriptions.find_by_notification_type(subscribable_type.to_s).delete # TODO: this should destroy associated recurrence as well (if it exists)
          end  
        end
      end
    end
  
    # TODO: untested (except via integration)
    def timezone_changed?
      changed.include?('timezone')
    end
    
    # TODO: untested (except via integration) (and this will use the notification class's default settings)
    def update_recurrent_subscriptions
      notification_type_subscriptions.recurrent.each do |recurrent_subscription| 
        recurrent_subscription.recurrence.update_attributes(:starts_at => ActiveSupport::TimeZone[timezone].parse("#{Date.today.to_s} #{recurrent_subscription.notification_type.constantize.time}"))
      end
    end
  end
end