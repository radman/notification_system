class NotificationObserver < ActiveRecord::Observer
  def after_create(notification)
    if notification.is_a?(EmailNotification)
      notification.send # send might be a reserved keyword (?)
    end
  end
end