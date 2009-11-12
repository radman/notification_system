require File.dirname(__FILE__) + '/../spec_helper'

# TODO: write some integration specs
describe "Notification System" do
  
  it "when user changes changes their timezone, all their recurrent subscriptions should be updated appropriately" do
    u = User.make :timezone => 'Eastern Time (US & Canada)'
    t = ActiveSupport::TimeZone[u.timezone].parse("#{Date.today.to_s} #{DailyNotification.time}")
    r = Recurrence.make :interval => DailyNotification.interval, :starts_at => t

    NotificationTypeSubscription.make :subscriber => u, :notification_type => 'DailyNotification', :recurrence => r
    puts r.reload.starts_at
    # lambda {
      u.update_attributes(:timezone => 'Pacific Time (US & Canada)')
    # }.should change(r, :starts_at)
    puts r.reload.starts_at
  end
  
end