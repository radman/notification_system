class CoolEventObserver < ActiveRecord::Observer
  def after_create(event)
    event.subscriptions.select(&:includes_emails?).each do |subscription|
      EmailNotification.create! :start_date => Time.now, :subscription => subscription, :event => event
    end
  end
end