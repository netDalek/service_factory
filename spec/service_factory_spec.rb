require "spec_helper"
require "service_factory"

describe ServiceFactory do
  before do
    ServiceFactory.register do |i|
      sample_var String
      sample_block { Object.new }
      sample_string { |s| String.new(s) }

      memoize do
        memo_var String
        memo_block { Object.new }
      end

      var_after_memo { Object.new }
    end
  end

  context 'when memoization is off' do
    context "when class given" do
      it "instantiates it every time" do
        expect(ServiceFactory.sample_var.object_id).not_to eq(ServiceFactory.sample_var.object_id)
      end
      it "instantiates it without args" do
        expect(ServiceFactory.sample_var).to be_instance_of(String)
      end
      it "instantiates it with args" do
        expect(ServiceFactory.sample_var("sample")).to eq("sample")
      end
    end

    context "when block given" do
      it "executes block without args" do
        expect(ServiceFactory.sample_block).to be_instance_of(Object)
      end
      it "executes block with args" do
        expect(ServiceFactory.sample_string("sample")).to eq("sample")
      end
      it "executes block every time" do
        expect(ServiceFactory.sample_block).not_to eq(ServiceFactory.sample_block)
      end
    end
  end

  context 'when memoization is on' do
    context "when class given" do
      it "instantiates it only once" do
        expect(ServiceFactory.memo_var.object_id).to eq(ServiceFactory.memo_var.object_id)
      end
      it "instantiates it without args" do
        expect(ServiceFactory.memo_var).to be_instance_of(String)
      end
    end

    context "when block given" do
      it "executes block only once" do
        expect(ServiceFactory.memo_block).to eq(ServiceFactory.memo_block)
      end
      it "executes block without args" do
        expect(ServiceFactory.memo_block).to be_instance_of(Object)
      end
    end

    it "doesn't memoize values after the end of the block" do
      expect(ServiceFactory.var_after_memo.object_id).not_to eq(ServiceFactory.var_after_memo.object_id)
    end
  end

  it "uses current environment data" do
    ServiceFactory.register do |i|
      env :development, :test do
        sample_var { "test2" }
      end
    end
    expect(ServiceFactory.sample_var).to eq("test2")
  end

  it "ignores data from another environment" do
    ServiceFactory.register do |i|
      sample_var { "test1" }
      env :production, :development do
        sample_var { "test2" }
      end
    end
    expect(ServiceFactory.sample_var).not_to eq("test2")
  end
end
