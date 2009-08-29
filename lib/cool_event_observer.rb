class CoolEventObserver < ActiveRecord::Observer
  def after_create(cool_event)
    if cool_event.subscriber.subscribed_to_cool_email?(cool_event.class)
      cool_event.send_email_notification
    end
  end
end