class CoolEventObserver < ActiveRecord::Observer
  def after_create(cool_event)
    if cool_event.subscription.wants_emails?
      cool_event.send_email_notification
    end
  end
end