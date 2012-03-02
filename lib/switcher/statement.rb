module Switcher
  class Statement
    def initialize(instance, spec, state_current=nil, state_prev=nil)
      @instance = instance

      @spec = spec

      @state_prev    = state_prev
      @state_current = state_current
    end

    attr_reader :name, :states, :state_prev

    def state_current
      (@state_current || @spec.states_list.first).to_sym
    end

    def state_prev
      @state_prev ? @state_prev.to_sym : nil
    end

    def publish(event, args)
      states = @spec.states
      state  = state_current

      return unless states.has_key?(state)

      facade = Facade.new(args)

      ["before_#{event}", event.to_s].each do |ev|
        states[state].trigger(ev, facade, @instance, args)
      end

      set_state(facade)

      states[state].trigger("after_#{event}", facade, @instance, args)
    end

  private

    def set_state(facade)
      unless facade.stopped || facade.target_state.nil?
        @state_prev    = state_current
        @state_current = facade.target_state.to_sym
      end
    end

  end
end