require File.dirname(__FILE__) + '/../spec_helper'

describe "Helpers" do
  
  describe "notification_settings_form_for" do
        
    it "should return Radu was here" do
      ClassWithHelpers.new.notification_settings_form_for.should == 'radu was here'
    end
    
  end
  
end