module Notifications
  module UserExtension
    
    def self.included(base)
      base.class_eval do
        include EventSubscriber

        has_many :events, :foreign_key => 'subscriber_id', :dependent => :destroy
      end
    end   
        
  end
end