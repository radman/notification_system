module NotificationSystem
  module UserExtension
    def self.included(base)
      base.class_eval do
        has_many  :notification_type_subscriptions, 
                  :class_name => 'NotificationSystem::NotificationTypeSubscription', 
                  :foreign_key => 'subscriber_id'
    #     serialize :notification_types
    #     validate :notification_types_are_valid, :if => :notification_types_changed?
      end
    end
    
    def wants_notification?(notification)
      notification.recipient == self && is_subscribed_to_notification_type?(notification.type)
    end
    
    def is_subscribed_to_notification_type?(notification_type)
      notification_type_subscriptions.exists?(:notification_type => notification_type)
    end
      
    # def notification_types=(val)
    #   val.delete('') if val.is_a?(Array) && val.include?('')
    #   super(val)
    # end
        
    private
    

    # ###################################
    # ## VALIDATION HELPERS
    # ###################################
    # 
    # # TODO: measure performance
    # def notification_types_are_valid
    #   unless self.notification_types.nil? || is_notification_type_array?(self.notification_types)
    #     errors.add :notification_types, 'must either be nil or an array of symbols/strings corresponding to subtypes of Notification'
    #   end
    # end
    # 
    # def notification_types_changed?
    #   self.changed.include?('notification_types')
    # end    
    # 
    # 
    # ###################################
    # ## OTHER METHODS
    # ###################################
    # 
    # def is_notification_type_array?(obj)
    #   obj.is_a?(Array) && obj.select { |x| references_notification_type?(x) }.size == obj.size
    # end
    # 
    # def references_notification_type?(obj)
    #   return false unless is_symbol?(obj) || is_non_empty_string?(obj)
    #   
    #   begin
    #     defined?(obj.to_s.camelize.constantize) && 
    #     obj.to_s.camelize.constantize.superclass == Notification
    #   rescue NameError
    #     return false
    #   end
    # end
    # 
    # def is_symbol?(obj)
    #   obj.is_a?(Symbol)
    # end
    # 
    # def is_non_empty_string?(obj)
    #   obj.is_a?(String) && !obj.blank?
    # end
  end
end