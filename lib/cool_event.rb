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
      User.find_by_sql "SELECT * FROM users WHERE cool_event_subscriptions LIKE '%#{self.to_s}%'"
    end
    
    private
    
    def load_subclasses
      Dir[RAILS_ROOT + '/app/models/cool_events/*_cool_event.rb'].each do |file|
        @@types << File.basename(file, '.rb').camelize.constantize
      end      
    end
    
  end
  
  def send_email_notification
    method_name = 'deliver_' + self.class.to_s.gsub(/CoolEvent$/, '').underscore
    NotificationMailer.send(method_name, self)
  end 
  
end