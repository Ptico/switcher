module Switcher
  class Facade
    def initialize(data, target_state=nil)
      @args    = data
      @stopped = false
      @target_state = target_state
    end

    attr_reader :args, :stopped, :target_state

    def stop
      @stopped = true
    end

    alias :restrict :stop

    def switch_to(state)
      @target_state = state.to_sym
    end
  end
end