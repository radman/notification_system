require 'net/smtp'

module NotificationSystem
  class Notification < ActiveRecord::Base
    belongs_to :recipient, :class_name => 'User'
    belongs_to :event, :class_name => 'NotificationSystem::Event'
    
    validates_presence_of :recipient, :date
        
    named_scope :pending, lambda { { :conditions => ['sent_at IS NULL AND date <= ?', Time.now.utc] } }
    named_scope :sent,    lambda { { :conditions => ['sent_at IS NOT NULL'] } }
    named_scope :created_after, lambda { |date| { :conditions => ['created_at > ?', date.utc] } }
            
    def deliver
      if self.recipient.wants_notification?(self)
        Notification.mailer_class.send("deliver_#{self.class.template_name}", self)      
        self.update_attributes!(:sent_at => Time.now.utc)
      else
        self.destroy
      end
    end
    
    class << self
      attr_accessor :mailer
                   
      def deliver_pending
        pending.each do |notification|
          begin
            notification.deliver
          rescue Net::SMTPSyntaxError => exception
            NotificationSystem.log("Net::SMTPSyntaxError (notification_id = #{notification.id})")
            NotificationSystem.report_exception(exception)
          rescue Exception => exception
            NotificationSystem.log("Exception of type #{exception.class} (notification_id = #{notification.id})")
            NotificationSystem.report_exception(exception)
          end
        end
      end

      def types
        @types ||= load_types
      end      
      
      def subscribable_types
        @subscribable_types ||= types.select { |type| type.subscribable? }
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
      
      ###################################
      ## Pretty Syntax For Organization
      ###################################

      def title(title=nil)
        title.nil? ? @title : @title = title
      end

      def group(group=nil)
        group.nil? ? @group : @group = group
      end
      
      ###################################
      ## Recurrences
      ###################################
      attr_reader :interval, :time

      def every(interval, options = {})
        raise ArgumentError, 'No time specified in :at attribute' if options[:at].nil?
        @interval = interval
        @time = options[:at]
      end
      
      def recurrent?
        @interval.present?
      end      
            
      private

      # PRE-CONDITION: types must be loaded into memory (should be done in init.rb)
      def load_types
        ObjectSpace.enum_for(:each_object, class << NotificationSystem::Notification; self; end).to_a - [NotificationSystem::Notification]
      end
    end
      
  end
end
