require 'spec_helper'

describe <%= class_name %> do
  it "should create a new instance given valid attributes" do
    <%= class_name %>.make.should_not be_nil
  end
end
