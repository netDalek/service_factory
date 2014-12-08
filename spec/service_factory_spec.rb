require "spec_helper"
require "service_factory"

describe ServiceFactory do
  before do
    ServiceFactory.register do |i|
      sample_var String
      sample_block { Object.new }
      sample_string { |s| String.new(s) }
    end
  end

  context "when class given" do
    it "instantiates it every time" do
      ServiceFactory.sample_var.object_id.should_not == ServiceFactory.sample_var.object_id
    end
    it "instantiates it without args" do
      ServiceFactory.sample_var.should be_instance_of(String)
    end
    it "instantiates it with args" do
      ServiceFactory.sample_var("sample").should == "sample"
    end
  end

  context "when block given" do
    it "executes block without args" do
      ServiceFactory.sample_block.should be_instance_of(Object)
    end
    it "executes block with args" do
      ServiceFactory.sample_string("sample").should == "sample"
    end
    it "executes block every time" do
      ServiceFactory.sample_block.should_not == ServiceFactory.sample_block
    end
  end

  it "uses current environment data" do
    ServiceFactory.register do |i|
      env :development, :test do
        sample_var { "test2" }
      end
    end
    ServiceFactory.sample_var.should == "test2"
  end

  it "ignores data from another environment" do
    ServiceFactory.register do |i|
      sample_var { "test1" }
      env :production, :development do
        sample_var { "test2" }
      end
    end
    ServiceFactory.sample_var.should_not == "test2"
  end
end
