Notification System
===================

The Noomii notification system!

Note: This plugin does NOT handle scheduling. Use another plugin such as "whenever" or "backgroundrb" for scheduling.

TODO
----

1. improve this README file
2. add recurring notifications
3. figure out how to integrate with flash notifications
4. add real 'instant' notifications (some schedulers use cron, for which the smallest interval is 1 minute)
5. provide a sample schedule.rb file (for whenever) ??
6. title syntax sugar on notification classes
7. view helpers
8. properly test subclasses method on notification model
9. follow proper guidelines for plugins: http://guides.rubyonrails.org/plugins.html

Installation
------------

    script/generate notification_system_migration
    rake db:migrate

Domain
------

### Notifications ###

A notification represents a bunch of information scheduled to be delivered to a particular user. A notification may be associated to an event, and users can subscribe / unsubscribe to any notification.

A notification is considered pending on and after its scheduled delivery date, if it has not been sent. Notifications are NOT sent automatically. You will need to use a scheduler of some sort to periodically call `Notification.deliver_pending`. This will grab all pending notifications, and deliver them to their recipients IF they are subscribed to receive that type of notification. IF they are not subscribed, the pending notification is destroyed.

Delivery assumes the existence of a `NotificationMailer`. To modify the mailer do something like the following:

    NotificationSystem::Notification.mailer = :user_mailer

The mailer method name will have to correspond to the notification class name. For example, a notification class called `NewCommentNotification` will try to use the `new_comment_notification` mailer method.

TODO: explain this a bit better

### Events ###

Events help in associating a particular context to a notification. In addition, they help organize the notification creation.

TODO: explain this a bit better


Usage
-----

### Generating New Notification Types ###

    script/generate notification new_comment
    
This will generate `app/models/notifications/new_comment_notification.rb`

### Generating New Event Types ###

    script/generate event new_user

This will generate `app/models/events/new_user_event.rb`

### Triggering Events ###

    NewUserEvent.trigger :source => source_object, :arg1 => 'blah', :arg2 => [1,2,3], ..., :argn => 'wow'
    
If successful, this will create a new event instance with a `source`. If no extra arguments are specified, it will be created with a nil data attribute. If extra arguments are specified, the data attribute will contain a serialized hash of the extra arguments.

TODO: explain better
    
### Creating Notifications ###

Notifications require a recipient and a date, and can optionally be associated to an event.

    NewCommentNotification.create! :recipient => some_user, :date => Time.now, :event => random_event_instance

### Notification Subscription ###

    user.notification_types = [:new_comment_notification, :tagged_in_photo_notification]

Copyright (c) 2009 Radu Vlad, released under the MIT license
