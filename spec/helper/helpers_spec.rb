require File.dirname(__FILE__) + '/../spec_helper'

describe "Helpers" do
  
  describe "ActionView::Base" do
    it "should have a notification_settings_form_for instance method" do
      ActionView::Base.instance_methods.should include('notification_settings_form_for')
    end
  end
  
  # describe "notification_settings_form_for" do        
  #   it "should return Radu was here" do
  #     ClassWithHelpers.new.notification_settings_form_for.should == 'radu was here'
  #   end    
  # end
  
end