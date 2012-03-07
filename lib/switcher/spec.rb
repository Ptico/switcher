require 'switcher/listener'
require 'switcher/facade'

module Switcher
  class Spec
    def initialize(name, options={})
      @name        = name.to_sym
      @states      = {}
      @states_list = []
      @subscribers = []
    end

    attr_reader :name, :states, :states_list, :subscribers

    def state(name, &block)
      listener = Listener.new(name)
      listener.instance_eval(&block) if block_given?

      @states_list << name.to_sym
      @states[name.to_sym] = listener
    end

    def notify(*list)
      @subscribers = list
    end

  end
end