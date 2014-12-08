require "service_factory/version"

module ServiceFactory
  def register(&block)
    @factory = Builder.new.build(&block)
  end
  module_function :register

  def self.method_missing(m, *args)
    if @factory.memoized_values.include?(m)
      @factory.memoized_values[m]
    elsif @factory.blocks.include?(m)
      @factory.blocks[m].call(*args)
    else
      super
    end
  end

  class FactoryInstance
    attr_reader :blocks, :memoized_values
    def initialize(blocks, memoized_values)
      @blocks = blocks
      @memoized_values = memoized_values
    end
  end

  class Builder
    def initialize
      @blocks = {}
      @memoized_values = {}
      @memoization = false
    end

    def build(&block)
      instance_eval(&block)
      FactoryInstance.new(@blocks, @memoized_values)
    end

    def method_missing(m, *args, &block)
      if block_given?
        define_from_block(m, args, &block)
      elsif args.first.is_a?(Class)
        cl = args.first
        define_from_class(m, cl, &block)
      else
        super
      end
    end

    def define_from_block(m, args, &block)
      if @memoization
        @memoized_values[m] = block.call
      else
        @blocks[m] = block
      end
    end

    def define_from_class(m, cl, &block)
      if @memoization
        @memoized_values[m] = cl.new
      else
        @blocks[m] = Proc.new { |*class_args| cl.new(*class_args) }
      end
    end

    def env(*environments, &block)
      if environments.map{|e| e.to_s}.include?(Rails.env)
        instance_eval(&block)
      end
    end

    def memoize(&block)
      @memoization = true
      instance_eval(&block)
      @memoization = false
    end
  end
end
