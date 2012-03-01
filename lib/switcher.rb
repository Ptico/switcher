require "switcher/version"
require 'switcher/spec'
require 'switcher/statement'

module Switcher
  module ClassMethods
    def switcher(name, options={}, &block)
      self.class_variable_defined?(:@@__specs__) or self.class_variable_set(:@@__specs__, [])

      spec = Spec.new(name, options)
      spec.instance_eval(&block)

      spec_name = spec.name

      self.class_variable_get(:@@__specs__) << spec

      self.class_eval do
        define_method(:"#{spec_name}_spec") { spec }
        define_method(:"#{spec_name}_prev") { self.instance_variable_get(:"@#{spec_name}_statement").state_prev }

        define_method(:"#{spec_name}") { self.instance_variable_get(:"@#{spec_name}_statement").state_current }

        events = []

        spec.states.each_pair do |state_name, state|
          define_method(:"#{spec_name}_#{state_name}?") do
            state_name == self.send(:"#{spec.name}")
          end

          events << state.event_names
        end

        events.flatten.each do |event_name|
          define_method(:"can_#{event_name}?") do
            self.class.class_variable_get(:@@__specs__).map { |spc|
              spc.states[self.send(:"#{spc.name}")].event_names.include?(event_name)
            }.include?(true)
          end

          define_method(:"#{event_name}!") do |*args|
            self.class.class_variable_get(:@@__specs__).each do |spc|
              self.instance_variable_get(:"@#{spc.name}_statement").publish(event_name, args)
            end
          end
        end
      end
    end

    def new(*args, &block)
      instance = allocate
      instance.instance_eval { initialize(*args, &block) }
      instance.class.class_variable_get(:@@__specs__).each do |spc|
        instance.instance_variable_set(:"@#{spc.name}_statement", Statement.new(instance, spc))
      end
      instance
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end
end