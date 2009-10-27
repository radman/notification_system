require 'action_mailer'

# Notifications
class RandomNotification < NotificationSystem::Notification
  title 'random notification'
end
class NewCommentNotification < NotificationSystem::Notification
  title 'new comment'
end
class NotificationWithTitle < NotificationSystem::Notification
  title 'notification with title'
end
class NotificationWithoutTitle < NotificationSystem::Notification; end
class NotificationWithGroup < NotificationSystem::Notification
  group 'notification with group'
end
class NotificationWithoutGroup < NotificationSystem::Notification; end
class NotificationWithRecurrentSetToTrue < NotificationSystem::Notification
  recurrent true
end
class NotificationWithRecurrentSetToFalse < NotificationSystem::Notification
  recurrent false
end
class NotificationWithoutRecurrent < NotificationSystem::Notification; end



# Events
class EventWithCommentSourceType < NotificationSystem::Event
  source_type :comment
end

class RandomEvent < NotificationSystem::Event; end

# User Extensions        
class User < ActiveRecord::Base
  include NotificationSystem::UserExtension
end

# Sample Classes
class Comment < ActiveRecord::Base
end

# For Testing Helpers
class ClassWithHelpers
  include ViewHelpers
end