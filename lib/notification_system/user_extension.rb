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
        (notification_types.include?(notification.class.to_s.underscore.to_sym) ||
         notification_types.include?(notification.class.to_s.underscore))
    end
    
    def notification_types=(val)
      val.delete('') if val.is_a?(Array) && val.include?('')
      super(val)
    end
        
    private
    

    ###################################
    ## VALIDATION HELPERS
    ###################################
    
    # TODO: measure performance
    def notification_types_are_valid
      unless self.notification_types.nil? || is_notification_type_array?(self.notification_types)
        errors.add :notification_types, 'must either be nil or an array of symbols/strings corresponding to subtypes of Notification'
      end
    end
    
    def notification_types_changed?
      self.changed.include?('notification_types')
    end    


    ###################################
    ## OTHER METHODS
    ###################################
    
    def is_notification_type_array?(obj)
      obj.is_a?(Array) && obj.select { |x| references_notification_type?(x) }.size == obj.size
    end
    
    def references_notification_type?(obj)
      return false unless is_symbol?(obj) || is_non_empty_string?(obj)
      
      begin
        defined?(obj.to_s.camelize.constantize) && 
        obj.to_s.camelize.constantize.superclass == Notification
      rescue NameError
        return false
      end
    end
    
    def is_symbol?(obj)
      obj.is_a?(Symbol)
    end
    
    def is_non_empty_string?(obj)
      obj.is_a?(String) && !obj.blank?
    end
  end
end