module Switcher
  class Statement
    def initialize(instance, spec)
      @instance = instance

      @spec = spec

      @state_prev    = nil
      @state_current = nil
    end

    attr_reader :name, :states, :state_prev

    def state_current
      @state_current || @spec.states_list.first
    end

    def publish(event, args)
      states = @spec.states

      return unless states.has_key?(state_current)

      facade = Facade.new(args)

      ["before_#{event}", event.to_s].each do |ev|
        states[state_current].trigger(ev, facade, @instance, args)
      end

      set_state(facade)

      states[state_current].trigger("after_#{event}", facade, @instance, args)
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