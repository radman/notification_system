require 'machinist/active_record'

User.blueprint do
end

RandomNotification.blueprint do
  recipient { User.make }
  date { Time.now }
end

NotificationTypeSubscription.blueprint do
  notification_type { 'RandomNotification' }
  subscriber { User.make }
end