# context: I'm in a scheduler and I need to grab all the notifications that I currently need to send and send them

# worker (every 5 seconds, for example)
Notification.send_pending_notifications

class Notification
  def self.send_pending_notifications
    # calculate which notifications need to be sent
  end
end

# Case 1: we only have instant notifications (i.e. notifications that only need to be sent once; and are usually sent when created)
# - these only need a sent_at attribute; if it is nil, it has not been sent
# - if we're not even keeping them, then we just need has_been_sent
#   - but since we only have instant notifications, and their existence implies that they have not been sent; we can just grab all existing notifications

# ASSUMPTION: delete sent notifications (if they're not reoccurring; but even then you might want them destroy (if you create a notification instance for each recurring event, rathert han just one per recurrence))

class Notification
  def self.send_pending_notifications
    all.each do |notification|
      notification.send_to_recipient
      notification.destroy # todo: only destroy if above line is successful
    end
  end
end

notification = notification.create! ...
Notification.send_pending_notifications

# Case 2: have scheduled notifications (i.e. notifications that need to be send at a particular time)
# - these need a date field specifying when the notification needs to be sent (we'll just use date)
# - they are still destroyed after being sent
# - case 1 can be handled a few diff ways
# => no date value implies instant
# => have the date value be set to the time when it was created (this seems more natural, and lets us handle both the same way)

class Notification
  named_scope :pending, lambda { :conditions => ['date <= ?', Time.now] } # todo: make sure time.now is actually the current time whenever the lambda is invoked

  def self.send_pending_notifications
    pending.each do |notification|
      notification.send_to_recipient
      notification.destroy # if above succeeds
    end
  end
end

# Case 3: recurring notifications
# - this requires three pieces of info:
#   - is_recurring?
#   - recurrence_interval
#   - end_date
# - the most straightforward efficient way is that if we have a recurring notification we don't destroy it until it's passed it's end date; instead, we increase the date by a given amount
# => not sure if this is cleaner than just duplicating the recurrent event with a modified date

class Notification
  named_scope :pending, lambda { :conditions => ['date <= ?', Time.now] } # todo: make sure time.now is actually the current time whenever the lambda is invoked

  def self.send_pending_notifications
    pending.each do |notification|
      notification.send_to_recipient
      notification.schedule_next_occurrence! if notification.is_recurring?
      notification.destroy
    end
  end
  
  def schedule_next_occurrence!
    if date + interval <= end_date
      Notification.create! :date =>
    end
  end
end

Notification
  start_date
  interval
  end_date
  times_sent
  
  
# if interval is nil, then it's not reoccurring -- send after start_date and delete
# if interval is 1 day, and start_date is now

(now, end_of_year, 1day, 0) : send
(now, end_of_year, 1day, 1)

to_send_at = (notification.start_date + times_sent * interval)

if to_send_at <= end_date
  pending = to_send_at <= Time.now
else
  destroy
end

# Question: Above model is good; but how are plugin users gonna specify which notifications to send on events; and how can we allow front-end users to change frequency of certain notifications
# - the latter requires some sort of rule hierarchy
# - the former is unknown
# - also, having only one notification view per event is somewhat restrictive
# => on second thought, each event should have one notification (views are a diff story), there don't ned to be two totally diff notifcations that one event happened
# => i.e. it's actually a 1-1 relation
# => not true; each subscription will have one event; because we may need to notify  many users
# => althooooough, you could just say that a single notification has many recipients!!
# =>  BUT, this would fuck up personalization

# Answer for former:
# => plugin users don't specify which notifications to send, this is handled by event_observer which checks subscriptions
# => plugin users do need the ability to easily edit notification schedules;
# => in fact, it seems much more natural to store the scheduling info on the subscription object (which plugin users already have access to)
# => a notification also has access to the subscription
# => we need to note, however, that this is an *event_type_subscription* and not a *notification_subscription*

:Radu
  :event_type_subscription
    :event_type => NewNoomiiUserEvent
    :includes_emails => true
    
    :start_date => "August 6, 2009"
    :end_date => "August 6, 2010"
    
    :interval => 0 # no recurrence
    
    :times_notified => 0
    

# The problem with keeping the entire schedule on event_type is that it doesn't keep track of whether individual notifications have been sent;
# unless we use their existence

# BIG ISSUE: Plugin user may require event-less notifications. Reminders for example, are event-less.


