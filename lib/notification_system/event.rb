module NotificationSystem
  class Event < ActiveRecord::Base
    belongs_to :source, :polymorphic => true
  end
end