require 'action_mailer'

# Notifications
class RandomNotification < NotificationSystem::Notification; end
class UpcomingCoachingSessionNotification < NotificationSystem::Notification; end
class NewCoachingSessionNotification < NotificationSystem::Notification; end

# Events
class RandomEvent < NotificationSystem::Event; end
  
class NewCoachingSessionEvent < NotificationSystem::Event
  def after_create
    coaching_session = self.source
    coaching_relationship = coaching_session.coaching_relationship

    other_user = (coaching_session.creator == coaching_relationship.coach) ? 
      coaching_relationship.coachee :
      coaching_relationship.coach    
    
    NewCoachingSessionNotification.create! :date => Time.now, :recipient => other_user, :event => self
    UpcomingCoachingSessionNotification.create! :date => coaching_session.date - 1.day, :recipient => coaching_relationship.coach, :event => self
    UpcomingCoachingSessionNotification.create! :date => coaching_session.date - 1.day, :recipient => coaching_relationship.coachee, :event => self
    RandomNotification.create! :date => coaching_session.date - 1.day, :recipient => coaching_relationship.coach, :event => self
    RandomNotification.create! :date => coaching_session.date - 1.day, :recipient => coaching_relationship.coachee, :event => self
  end
end

# User Extensions        
class User < ActiveRecord::Base
  include NotificationSystem::UserExtension
end

# Sample Classes
class CoachingRelationship < ActiveRecord::Base
  belongs_to :coach, :class_name => 'User'
  belongs_to :coachee, :class_name => 'User'
end

class CoachingSession < ActiveRecord::Base
  belongs_to :coaching_relationship
  belongs_to :creator, :class_name => 'User'
  
  def after_create
    NewCoachingSessionEvent.create! :source => self
  end
end
