module NotificationSystem
  class Notification < ActiveRecord::Base
    belongs_to :recipient, :class_name => 'User'
    belongs_to :event, :class_name => 'NotificationSystem::Event'
    
    validates_presence_of :recipient, :date
        
    named_scope :pending, lambda { { :conditions => ['sent_at IS NULL AND date <= ?', Time.now] } }
    named_scope :sent,    lambda { { :conditions => ['sent_at IS NOT NULL'] } }
    named_scope :created_after, lambda { |date| { :conditions => ['created_at > ?', date] } }
            
    def deliver
      if self.recipient.wants_notification?(self)
        Notification.mailer_class.send("deliver_#{self.class.template_name}", self)      
        self.update_attributes!(:sent_at => Time.now)
      else
        self.destroy
      end
    end
    
    class << self
      attr_accessor :mailer
                   
      def deliver_pending
        pending.each do |notification|
          notification.deliver
        end
      end

      def types
        @types ||= load_types
      end      
      
      def subscribable_types
        @subscribable_types ||= load_types.select { |type| type.subscribable? }
      end
      
      def subscribable?
        !self.title.nil?
      end      
      
      def mailer
        @mailer || :notification_mailer
      end
      
      def mailer_class
        mailer.to_s.classify.constantize
      end

      def template_name
        return self.to_s.underscore
      end      
      
      def title(title=nil)
        title.nil? ? @title : @title = title
      end

      def group(group=nil)
        group.nil? ? @group : @group = group
      end
      
      private
      
      def load_types
        Dir[File.join(RAILS_ROOT, 'app', 'models', 'notifications', '*')].collect do |file|
          File.basename(file, '.rb').camelize.constantize
        end
      end
    end
      
  end
end