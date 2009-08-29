class CoolEvent < ActiveRecord::Base
  belongs_to :subscriber, :class_name => 'User'
  belongs_to :source, :polymorphic => true

  class << self
    @@types = []
    
    # The following options are required:
    #  :source  => the object where the event was triggered (although this can be any relevant object)
    def trigger(options = {})
      self.subscribers_to(options[:source]).each do |subscriber|
        self.create! :subscriber => subscriber, :source => options[:source]
      end      
    end  

    def types
      load_subclasses if @@types.empty?
      @@types
    end

    protected

    def subscribers_to(source)
      EventSubscription.of_type(self).collect(&:subscriber)
    end
    
    private
    
    def load_subclasses
      Dir[RAILS_ROOT + '/app/models/events/*_event.rb'].each do |file|
        @@types << File.basename(file, '.rb').camelize.constantize
      end      
    end
    
  end
  
  def subscription
    subscriber.event_subscriptions.find_by_event_type(self.class.to_s)
  end
  
  def send_email_notification
    method_name = 'deliver_' + self.class.to_s.gsub(/Event$/, '').underscore
    NotificationMailer.send(method_name, self)
  end 
  
end