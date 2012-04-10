module Switcher
  class Statement
    def initialize(instance, spec, state_current=nil, state_prev=nil)
      @spec          = spec
      @instance      = instance
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

    def publish(event, target, args)
      states = @spec.states
      state  = state_current

      return unless states.has_key?(state)

      listener = states[state]
      facade   = Facade.new(target, args)

      ["before_#{event}", event.to_s].each do |ev|
        listener.trigger(ev, facade, @instance, args)
      end

      set_state(facade)

      listener.trigger("after_#{event}", facade, @instance, args)

      return if facade.bubble_cancelled

      unless @spec.subscribers.empty?
        @spec.subscribers.each do |sub|
          sub_instance = @instance.send(sub.to_sym)

          if sub_instance.respond_to?(:each)
            sub_instance.each { |ti| sub_switch(ti, target, event, args) }
          else
            sub_switch(sub_instance, target, event, args)
          end
        end # each
      end # unless

      return @instance
    end # def publish

    def force_state(state)
      return unless @spec.states_list.include?(state.to_sym) # FIXME - raise exception

      @state_prev    = state_current
      @state_current = state.to_sym

      return @instance
    end

  private

    def set_state(facade)
      unless facade.stopped || facade.target_state.nil?
        @state_prev    = state_current
        @state_current = facade.target_state.to_sym
      end
    end

    def sub_switch(sub, target, event, args)
      sub.switch_from(target, event, args) if sub.respond_to?(:switch_from)
    end

  end # class Statement
end