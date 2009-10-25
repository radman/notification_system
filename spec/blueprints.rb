require 'machinist/active_record'

User.blueprint {}
Comment.blueprint {}

RandomNotification.blueprint do
  recipient { User.make }
  date { Time.now }
end

NotificationTypeSubscription.blueprint do
  notification_type { 'RandomNotification' }
  subscriber { User.make }
end

