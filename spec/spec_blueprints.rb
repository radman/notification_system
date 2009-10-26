require 'machinist/active_record'

NotificationSystem::Recurrence.blueprint do
  interval { 1.week }
  starts_at { Time.now }
end

NotificationSystem::NotificationTypeSubscription.blueprint do
  notification_type { 'RandomNotification' }
  subscriber { User.make }
end

User.blueprint {}
RandomEvent.blueprint {}

RandomNotification.blueprint do
  recipient { User.make }
  date { Time.now }
end

NewCommentNotification.blueprint do
  recipient { User.make }
  date { Time.now }  
end

Comment.blueprint {}