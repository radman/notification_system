require 'machinist/active_record'

NotificationSystem::Recurrence.blueprint {}
NotificationSystem::NotificationTypeSubscription.blueprint do
  notification_type { 'RandomNotification' }
  subscriber { User.make }
end

User.blueprint {}

RandomNotification.blueprint do
  recipient { User.make }
  date { Time.now }
end

Comment.blueprint {}