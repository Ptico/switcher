require 'switcher/spec'

module Switcher
  module Machine

    module ClassMethods
      def switcher(name, options={}, &block)
        self.class_variable_defined?(:@@__specs__) or self.class_variable_set(:@@__specs__, [])

        spec = Spec.new(name, options)
        spec.instance_eval(&block)

        spec_name = spec.name

        self.class_variable_get(:@@__specs__) << spec # dup and destroy?

        self.class_eval do
          define_method(:"#{spec_name}_spec") { spec }
          define_method(:"#{spec_name}_prev") { spec.state_prev }

          define_method(:"#{spec_name}") { spec.state_current }

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
                spc.publish(self.send(:"#{spc.name}"), event_name, self, args)
              end
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