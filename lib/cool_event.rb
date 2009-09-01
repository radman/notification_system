class CoolEvent < ActiveRecord::Base
  belongs_to :source, :polymorphic => true
  has_many :notifications
  
  class << self 
    def subscriptions
      EventTypeSubscription.of_type(self)
    end
        
    # The following options are required:
    #  :source  => the object where the event was triggered (although this can be any relevant object)
    def trigger(options = {})
      event = self.create! :source => options[:source]
      
      self.subscriptions.select(&:includes_emails?).each do |subscription|
        EmailNotification.create! :subscription => subscription, :event => event
      end
    end
    
    def template_name
      self.to_s.gsub(/Event$/, '').underscore
    end
  end
end