require File.dirname(__FILE__) + '/../spec_helper'

describe "Recurrence" do
  it "should be invalid without an interval" do
    recurrence = Recurrence.new
    recurrence.should_not be_valid
  end

  it "should be invalid with a negative interval" do
    recurrence = Recurrence.new :interval => -7
    recurrence.should_not be_valid
  end  
  
  it "should be valid with a positive non-zero interval" do
    recurrence = Recurrence.new :interval => 1
    recurrence.should be_valid
  end  
end
