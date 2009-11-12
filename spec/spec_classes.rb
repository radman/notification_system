require 'action_mailer'

###################################
## Notifications
###################################

class EmptyNotification < NotificationSystem::Notification; end
class RandomNotification < NotificationSystem::Notification
  title 'random notification'
end
class NewCommentNotification < NotificationSystem::Notification
  title 'new comment'
end
class NotificationWithTitle < NotificationSystem::Notification
  title 'notification with title'
end
class NotificationWithGroup < NotificationSystem::Notification
  group 'notification with group'
end
class DailyNotification < NotificationSystem::Notification
  every 1.day, :at => '6:00am'
end

###################################
## Events
###################################

class EventWithCommentSourceType < NotificationSystem::Event
  source_type :comment
end
class RandomEvent < NotificationSystem::Event; end


###################################
## User Extensions
###################################
       
class User < ActiveRecord::Base
  include NotificationSystem::UserExtension
end


###################################
## Sample Classes
###################################

class Comment < ActiveRecord::Base
end


###################################
## For Testing Helpers
###################################

class ClassWithHelpers
  include ViewHelpers
end