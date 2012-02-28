module Switcher
  class Listener
    def initialize(name)
      @events      = {}
      @event_names = []
      @name        = name
    end

    attr_reader :events, :event_names, :name

    def before(event, options={}, &block)
      options[:allow_switch] = true
      data = { callback: block, options: options }
      @events["before_#{event}"] = data
    end

    def on(event, options={}, &block)
      options[:allow_switch] = true
      data = { callback: block, options: options }
      @event_names << event.to_sym
      @events[event.to_s] = data
    end

    def after(event, options={}, &block)
      data = { callback: block, options: options }
      @events["after_#{event}"] = data
    end

    def trigger(event, facade, instance, args)
      if ev = @events[event]
        instance.instance_exec(facade, *args, &ev[:callback]) if ev[:callback].respond_to?(:call)
        if !facade.stopped && ev[:options][:allow_switch] && switch_to = ev[:options][:switch_to]
          facade.switch_to(switch_to)
        end
      end
    end
  end
end