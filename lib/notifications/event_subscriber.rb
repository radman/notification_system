module Notifications
  module EventSubscriber
    def self.included(base)
      base.class_eval do        
        has_many :event_subscriptions, :foreign_key => 'subscriber_id', :dependent => :destroy
      end
    end
  
    def subscribe_to_event(event_class, wants_emails = true)
      if !self.subscribed_to_event?(event_class)
        self.event_subscriptions << EventSubscription.create(:event_type => event_class.to_s, :wants_emails => wants_emails)
      end
    end
  
    def unsubscribe_from_event(event_class)
      self.event_subscriptions.find_by_event_type(event_class.to_s).destroy
      self.event_subscriptions.reload
    end
  
    def subscribed_to_event?(event_class)
      self.event_subscriptions.exists? :event_type => event_class.to_s
    end
  end
end