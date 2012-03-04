require 'switcher/listener'
require 'switcher/facade'

module Switcher
  class Spec
    def initialize(name, options={})
      @name        = name.to_sym
      @states      = {}
      @states_list = []
      @targets     = []
    end

    attr_reader :name, :states, :states_list, :targets

    def state(name, &block)
      listener = Listener.new(name)
      listener.instance_eval(&block) if block_given?

      @states_list << name.to_sym
      @states[name.to_sym] = listener
    end

    def notify(*list)
      @targets = list
    end

  end
end