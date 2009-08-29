module Notifications
  module CoolEmailSubscriber
    def self.included(base)
      base.class_eval do
        serialize :cool_email_subscriptions
      end
    end
    
    def subscribe_to_cool_email(cool_event_class)
      self.cool_email_subscriptions ||= []
      self.cool_email_subscriptions |= [cool_event_class.to_s]
    end
  
    def unsubscribe_from_cool_email(cool_event_class)
      self.cool_email_subscriptions.delete(cool_event_class.to_s)
    end
  
    def subscribed_to_cool_email?(cool_event_class)
      self.cool_email_subscriptions && self.cool_email_subscriptions.include?(cool_event_class.to_s)
    end  
  end
end