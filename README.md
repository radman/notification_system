Notifications
=============

The Noomii notification system!

Note: This plugin does not handle scheduling.

TODO
----

1. add configuration class for things like mailer
2. update this README
3. notifications should be associated to events (the association should be optional)
4. new spec: pending cannot include notifications that have already been sent

Installation
------------

    script/generate notification_system_migration
    rake db:migrate

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
