require "service_factory/version"

module ServiceFactory
  @blocks = {}

  def register(&block)
    Builder.new(@blocks).instance_eval(&block)
  end
  module_function :register

  def self.method_missing(m, *args)
    if @blocks.include?(m)
      @blocks[m].call(*args)
    else
      super
    end
  end

  class Builder
    def initialize(blocks)
      @blocks = blocks
    end

    def method_missing(m, *args, &block)
      if block_given?
        @blocks[m] = block
      elsif args.first.is_a?(Class)
        cl = args.first
        @blocks[m] = Proc.new { |*class_args| cl.new(*class_args) }
      else
        super
      end
    end

    def env(*environments, &block)
      if environments.map{|e| e.to_s}.include?(Rails.env)
        instance_eval(&block)
      end
    end
  end
end
