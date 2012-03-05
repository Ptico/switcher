module Switcher
  class Statement
    def initialize(instance, spec, state_current=nil, state_prev=nil)
      @instance = instance

      @spec = spec

      @state_prev    = state_prev
      @state_current = state_current
    end

    attr_reader :name, :states

    def state_current
      (@state_current || @spec.states_list.first).to_sym
    end

    def state_prev
      @state_prev ? @state_prev.to_sym : nil
    end

    def publish(event, original, args)
      states = @spec.states
      state  = state_current

      return unless states.has_key?(state)

      facade = Facade.new(original, args)

      ["before_#{event}", event.to_s].each do |ev|
        states[state].trigger(ev, facade, @instance, args)
      end

      set_state(facade)

      states[state].trigger("after_#{event}", facade, @instance, args)

      return if facade.bubble_cancelled

      if @spec.targets.length > 0
        @spec.targets.each do |target|
          target_instance = @instance.send(target.to_sym)
          if target_instance.respond_to?(:each)
            target_instance.each do |ti|
              ti.switch_from(original, event, args) if ti.respond_to?(:switch_from)
            end
          else
            target_instance.switch_from(original, event, args) if target_instance.respond_to?(:switch_from)
          end
        end
      end
    end

    def force_state(state)
      return unless @spec.states_list.include?(state.to_sym) # FIXME - raise exception
      @state_prev    = state_current
      @state_current = state.to_sym
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