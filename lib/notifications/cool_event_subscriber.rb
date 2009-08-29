module Notifications
  module CoolEventSubscriber
    def self.included(base)
      base.class_eval do        
        has_many :cool_event_subscriptions, :foreign_key => 'subscriber_id', :dependent => :destroy
      end
    end
  
    def subscribe_to_cool_event(cool_event_class, wants_emails = true)
      if !subscribed_to_cool_event?(cool_event_class)
        self.cool_event_subscriptions << CoolEventSubscription.create(:cool_event_type => cool_event_class.to_s, :wants_emails => wants_emails)
      end
    end
  
    def unsubscribe_from_cool_event(cool_event_class)
      self.cool_event_subscriptions.find_by_cool_event_type(cool_event_class.to_s).destroy
      self.cool_event_subscriptions.reload
    end
  
    def subscribed_to_cool_event?(cool_event_class)
      self.cool_event_subscriptions.exists? :cool_event_type => cool_event_class.to_s
    end
  end
end