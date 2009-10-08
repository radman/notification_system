class NotificationObserver < ActiveRecord::Observer
  def after_create(notification)
    # if notification.is_a?(EmailNotification)
    #   notification.send_to_recipient
    # end
  end
end