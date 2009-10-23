require File.dirname(__FILE__) + '/../spec_helper'

describe "Helpers" do
  
  describe "ActionView::Base" do
    it "should have a notification_settings_for instance method" do
      ActionView::Base.instance_methods.should include('notification_settings_for')
    end
  end
  
end