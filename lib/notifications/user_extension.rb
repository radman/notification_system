module Notifications
  module UserExtension
    
    def self.included(base)
      base.class_eval do
        include CoolEventSubscriber

        has_many :cool_events, :foreign_key => 'subscriber_id', :dependent => :destroy
      end
    end   
        
  end
end