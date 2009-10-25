Notification System
===================

The Noomii notification system!

Note: This plugin does NOT handle scheduling. Use another plugin such as "whenever" or "backgroundrb" for scheduling.

Installation
------------

    script/generate notification_system_migration
    rake db:migrate

Domain
------

### Notifications ###

A notification represents a bunch of information scheduled to be delivered to a particular user. A notification may be associated to an event, and users can subscribe / unsubscribe to any notification.

A notification is considered pending on and after its scheduled delivery date, if it has not been sent. Notifications are NOT sent automatically. You will need to use a scheduler of some sort to periodically call `Notification.deliver_pending`. This will grab all pending notifications, and deliver them to their recipients IF they are subscribed to receive that type of notification. IF they are not subscribed, the pending notification is destroyed.

Only notifications that have titles specified are considered subscribable. (TODO: somewhat iffy.. maybe change this in the future)

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

### Validating Event Source Type ###

    class CoolEvent < NotificationSystem::Event
      source_type :user
    end
    
This will ensure that the source's class is validated. If the type of the source is not User, this will add an error to the event instance: "source is not an instance of User".

TODO: explain better

### Triggering Events ###

    NewUserEvent.trigger :source => source_object, :arg1 => 'blah', :arg2 => [1,2,3], ..., :argn => 'wow'
    
If successful, this will create a new event instance with a `source`. If no extra arguments are specified, it will be created with a nil data attribute. If extra arguments are specified, the data attribute will contain a serialized hash of the extra arguments.

TODO: explain better
    
### Creating Notifications ###

Notifications require a recipient and a date, and can optionally be associated to an event.

    NewCommentNotification.create! :recipient => some_user, :date => Time.now, :event => random_event_instance

### Recurrences ###

*(WILL CHANGE VERY SOON -- RECURRENCES WILL INSTEAD BE ASSOCIATED TO SUBSCRIPTIONS)*

Recurrences must have a positive non-zero interval (specified in seconds). A recurrence can be associated to a notification as follows:

    notification.recurrence = Recurrence.create! :interval => 1.week, :end_date => 1.year.from_now

A notification is defined as recurrent if it is associated to a recurrence. To find out whether a notification is recurrent call

    notification.recurrent?

Once sent, a recurrent notification will schedule a copy of itself as defined in the recurrence. If an `end_date` is not specified the notification will recur forever.

### Notification Groups and Titles ###

    class NewCommentOnYourArticleNotification < NotificationSystem::Notification
      group 'Comments'
      title 'Someone commented on your article'
    end
    
These are the titles that will be displayed on the notification settings form. Specifying a title makes a notification subscribable.

Specifying a group will organize your notification settings form into groups. If you specify at least one group, then all notifications
without a group will be organized under 'Other'.

### Notification Subscription ###

    NotificationTypeSubscription.create! :subscriber => radu, :notification_type => 'CoolNotification'
    user.notification_type_subscriptions << ...
    user.is_subscribed_to_notification_type?('new_comment_notification')
    
### Notification Subscription Settings ###

    = notification_settings_for @user
    
### Notification Named Scopes ###

    Notification.pending
    Notification.sent

Copyright (c) 2009 Radu Vlad, released under the MIT license
