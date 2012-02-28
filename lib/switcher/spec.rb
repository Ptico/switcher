require 'switcher/listener'
require 'switcher/facade'

module Switcher
  class Spec
    def initialize(name, options={})
      @name        = name.to_sym
      @states      = {}
      @states_list = []
      @state_prev  = nil
    end

    attr_reader :name, :states, :state_prev

    def state(name, &block)
      listener = Listener.new(name)
      listener.instance_eval(&block) if block_given?

      @states_list << name.to_sym
      @states[name.to_sym] = listener
    end

    def current_state
      @current_state || @states_list.first
    end

    def publish(current_state, event, instance, args)
      facade = Facade.new(args)
      ["before_#{event}", event.to_s].each do |ev|
        @states[current_state.to_sym].trigger(ev, facade, instance, args)
      end
      set_state(facade)
      @states[current_state.to_sym].trigger("after_#{event}", facade, instance, args)
    end

  private

    def set_state(facade)
      unless facade.stopped && facade.target_state.nil?
        @state_prev    = @current_state
        @current_state = facade.target_state.to_sym
      end
    end
  end
end