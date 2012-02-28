require 'switcher/spec'

module Switcher
  module Machine

    module ClassMethods
      def switcher(name, options={}, &block)
        self.class_variable_defined?(:@@__specs__) or self.class_variable_set(:@@__specs__, [])

        spec = Spec.new(name, options)
        spec.instance_eval(&block)

        self.class_variable_get(:@@__specs__) << spec # dup and destroy?

        self.class_eval do
          define_method(:"#{spec.name}_spec") { spec }
          define_method(:"#{spec.name}_prev") { spec.state_prev }

          define_method(:"#{spec.name}") { spec.current_state }

          events = []

          spec.states.each_pair do |state_name, state|
            define_method(:"#{state_name}?") { state_name == self.send(:"#{spec.name}") }

            events << state.event_names
          end

          events.flatten.each do |event_name|
            define_method(:"can_#{event_name}?") { spec.states[self.send(:"#{spec.name}")].event_names.include?(event_name) }
            define_method(:"#{event_name}!") do |*args|
              spec.publish(self.send(:"#{spec.name}"), event_name, self, args)
            end
          end
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end