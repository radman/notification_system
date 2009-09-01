class NotificationObserver < ActiveRecord::Observer
  def after_create(notification)
    debugger
    if notification.is_a?(EmailNotification)
      notification.send_to_recipient
    end
  end
end