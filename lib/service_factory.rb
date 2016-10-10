require "service_factory/version"

module ServiceFactory
  @blocks = {}
  def register(&block)
    Builder.new(@blocks).build(&block)
  end
  module_function :register

  class << self

    def method_missing(m, *args)
      if @blocks.include?(m)
        @blocks[m].call(*args)
      else
        super
      end
    end

    def respond_to?(m, include_all=false)
      @blocks.include?(m) || super(m)
    end

    def public_method_defined?(m)
      respond_to?(m)
    end

  end

  class Builder
    class Error < RuntimeError; end
    class UnexpectedParams < Error; end

    def initialize(blocks)
      @blocks = blocks
      @memoized_values = {}
      @memoization = false
    end

    def build(&block)
      instance_eval(&block)
      @blocks
    end

    def method_missing(m, *args, &block)
      prepared_block = args_to_block(args, &block)
      if @memoization
        @blocks[m] = Proc.new { @memoized_values[m] ||= prepared_block.call }
      else
        @blocks[m] = prepared_block
      end
    end

    def args_to_block(args, &block)
      if block_given?
        block
      elsif args.first.is_a?(Class)
        cl = args.first
        Proc.new { |*class_args| cl.new(*class_args) }
      else
        raise UnexpectedParams.new("expected class or block")
      end
    end

    def env(*environments, &block)
      e = defined?(Rails) ? Rails.env : (ENV['RAILS_ENV'] || ENV['RACK_ENV'])
      if environments.map{|e| e.to_s}.include?(e)
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
