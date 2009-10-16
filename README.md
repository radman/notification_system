Notifications
=============

The Noomii notification system!

Note: This plugin does not handle scheduling.

TODO
----

1. update this README
2. notifications should be associated to events (the association should be optional)
3. new spec: pending cannot include notifications that have already been sent

Installation
------------

    script/generate notification_system_migration
    rake db:migrate

Domain
------

### Notifications ###

A notification represents a bunch of information scheduled to be delivered to a particular user. A notification may be associated to an event, and users can subscribe / unsubscribe to any notification.

A notification is considered pending on and after its scheduled delivery date. Notifications are NOT sent automatically. You will need to use a scheduler of some sort to periodically call `Notification.deliver_pending`. This will grab all pending notifications, and deliver them to their recipients IF they are subscribed to receive that type of notification. IF they are not subscribed, the pending notification is destroyed (TODO).

Delivery assumes the existence of a `NotificationMailer`. To modify the mailer do something like the following:

    NotificationSystem::Notification.mailer = :user_mailer

The mailer method name will have to correspond to the notification class name. For example, a notification class called `NewCommentNotification` will try to use the `new_comment_notification` mailer method.

TODO: explain this a bit better

### Events ###

Events help in associating a particular context to a notification. In addition, they help organize the notification creation.

TODO: explain this a bit better


Usage
-----

### Creating New Notification Types (TODO) ###

    script/generate notification new_comment
    
This will generate `app/models/notifications/new_comment_notification.rb`

### Creating New Events (TOFIX) ###

    script/generate event NewUser

This will generate `app/models/events/new_user_event.rb`

### Triggering Events ###

    NewUserEvent.trigger :source => source_object
    
### Creating Notifications ###

Notifications require a recipient and a date, and can optionally be associated to an event.

    NewCommentNotification.create! :recipient => some_user, :date => Time.now

### Notification Subscription ###

    user.notification_types = [:new_comment_notification, :tagged_in_photo_notification]

Copyright (c) 2009 Radu Vlad, released under the MIT license
