module Notifications
  module CoolEventSubscriber
    def self.included(base)
      base.class_eval do
        serialize :cool_event_subscriptions
      end
    end
  
    def subscribe_to_cool_event(cool_event_class)
      self.cool_event_subscriptions ||= []
      self.cool_event_subscriptions |= [cool_event_class.to_s]
    end
  
    def unsubscribe_from_cool_event(cool_event_class)
      self.cool_event_subscriptions.delete(cool_event_class.to_s)
    end
  
    def subscribed_to_cool_event?(cool_event_class)
      self.cool_event_subscriptions && self.cool_event_subscriptions.include?(cool_event_class.to_s)
    end
  end
end