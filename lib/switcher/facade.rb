module Switcher
  class Facade
    def initialize(target, data)
      @args    = data
      @stopped = false
      @bubble_cancelled = false
      @target_state     = nil
      @target  = target
    end

    attr_reader :args, :stopped, :target, :target_state, :bubble_cancelled

    def stop
      @stopped = true
      @bubble_cancelled = true
    end

    alias :restrict :stop

    def switch_to(state)
      @target_state = state.to_sym
    end

    def cancel_bubble
      @bubble_cancelled = true
    end
  end
end