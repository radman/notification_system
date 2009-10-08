class CoolEvent < ActiveRecord::Base
  belongs_to :source, :polymorphic => true
  has_many :notifications

  def subscriptions
    EventTypeSubscription.of_type(self.class)
  end  
  
  # Class Methods
  class << self
    # The following options are required:
    #  :source  => the object where the event was triggered (although this can be any relevant object)
    def trigger(options = {})
      event = self.create! :source => options[:source]
    end
  
    def template_name
      self.to_s.gsub(/Event$/, '').underscore
    end
  end
end