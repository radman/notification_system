module CoolNotifications
  module EventSubscriber
    def self.included(base)
      base.class_eval do        
        has_many :event_type_subscriptions, :foreign_key => 'subscriber_id', :dependent => :destroy
      end
    end
  
    def subscribe_to_event(event_class, includes_emails = true)
      if !self.subscribed_to_event?(event_class)
        self.event_type_subscriptions << EventTypeSubscription.create(:event_type => event_class.to_s, :includes_emails => includes_emails)
      end
    end
  
    def unsubscribe_from_event(event_class)
      self.event_type_subscriptions.find_by_event_type(event_class.to_s).destroy
      self.event_type_subscriptions.reload
    end
  
    def subscribed_to_event?(event_class)
      self.event_type_subscriptions.exists? :event_type => event_class.to_s
    end
  end
end