module NotificationSystem
  class Notification < ActiveRecord::Base
    belongs_to :recipient, :class_name => 'User'
    validates_presence_of :recipient_id, :date
    named_scope :pending, lambda { { :conditions => ['date <= ?', Time.now] } }
    
    def deliver
      NotificationMailer.send("deliver_#{template_name}", self)
      self.update_attributes!(:sent_at => Time.now)
    end
       
    def self.deliver_pending
      pending.each do |notification|
        notification.deliver if notification.recipient.wants_notification?(notification)
      end
    end 

    private
    
    def template_name
      return self.class.to_s.underscore
    end    
  end
end