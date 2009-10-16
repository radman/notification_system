module NotificationSystem
  module UserExtension
    def self.included(base)
      base.class_eval do
        serialize :notification_types
        validate :notification_types_are_valid, :if => :notification_types_changed?
      end
    end
    
    def wants_notification?(notification)
      notification && notification.recipient == self && 
      !notification_types.nil? && 
      !notification_types.empty? && 
      notification_types.include?(notification.class.to_s.underscore.to_sym)
    end
    
    private
    
    # TODO: clean this method up
    def notification_types_are_valid
      is_nil = self.notification_types.nil?
      is_an_array = !self.notification_types.is_a?(Array)
      
      if !self.notification_types.nil?
        if !self.notification_types.is_a?(Array)
          errors.add :notification_types, " must either be nil or an array of symbols to notification subclasses of Notification"
        elsif !self.notification_types.empty?
          # INVARIANT: notification_types is a non-empty array
          if !self.notification_types.select { |x| !x.is_a?(Symbol) }.empty? # check that it's only symbols
            errors.add :notification_types, " must either be nil or an array of symbols corresponding to subclasses of Notification" 
          else
            # INVARIANT: notification_types is a non-empty array of symbols
            invalid_references = self.notification_types.select do |x|
              begin
                cls = Module.const_get(x.to_s.classify)
                cls == Notification || !cls.ancestors.include?(Notification)
              rescue NameError
                true
              end
            end
            
            if !invalid_references.empty?
              errors.add :notification_types, " must either be nil or an array of symbols corresponding to subclasses of Notification"
            end             
          end
        end
      end      
    end
    
    def notification_types_changed?
      self.changed.include?('notification_types')
    end    
  end
end