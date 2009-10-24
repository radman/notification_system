module NotificationSystem
  class Event < ActiveRecord::Base
    belongs_to :source, :polymorphic => true
    serialize :data
    
    def self.trigger(attributes = {})
      source = attributes[:source]
      data = attributes.reject { |key,value| key == :source }
      self.create(:source => attributes[:source], :data => data.empty? ? nil : data)
    end
    
    def self.source_type(source_type)
      validate Proc.new { |e| 
        e.errors.add :source, "must be an instance of #{source_type.to_s.classify}" unless e.source.is_a?(source_type.to_s.classify.constantize)
      }
    end
  end
end