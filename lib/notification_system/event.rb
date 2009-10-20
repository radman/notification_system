module NotificationSystem
  class Event < ActiveRecord::Base
    belongs_to :source, :polymorphic => true
    serialize :data
    
    def self.trigger(attributes = {})
      source = attributes[:source]
      data = attributes.reject { |key,value| key == :source }
      self.create!(:source => attributes[:source], :data => data.empty? ? nil : data)
    end
  end
end