module Switcher
  module Object
    module Initializer
      def new(*args, &block)
        instance = allocate
        instance.instance_eval { initialize(*args, &block) }
        instance.class.class_variable_get(:@@__specs__).each do |spc| # TODO - move to something like Switcher.initial_statement(instance)
          instance.instance_variable_set(:"@#{spc.name}_statement", Statement.new(instance, spc))
        end
        instance
      end
    end

    module ClassMethods
      def switcher_pre_initialize(inst, spec)
        inst.class_eval do
          spec_name = spec.name

          define_method(:"#{spec_name}_spec") { spec }
          define_method(:"#{spec_name}_prev") { self.instance_variable_get(:"@#{spec_name}_statement").state_prev }

          define_method(:"#{spec_name}") { self.instance_variable_get(:"@#{spec_name}_statement").state_current }
          define_method(:"#{spec_name}=") { nil }

          define_method(:"#{spec_name}_force") { |state| self.instance_variable_get(:"@#{spec_name}_statement").force_state(state.to_sym) }

          events = []

          spec.states.each_pair do |state_name, state|
            define_method(:"#{spec_name}_#{state_name}?") do
              state_name == self.send(:"#{spec_name}")
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
              switch(event_name, *args)
            end
          end
        end
      end
    end

    def self.included(base)
      base.extend Switcher::ClassMethods
      base.extend Switcher::Object::Initializer
      base.extend Switcher::Object::ClassMethods
    end

    def switch(event, *args)
      switch_from(self.class, event, *args)
    end

    def switch_from(orig, event, *args)
      return false unless (self.respond_to?(:"can_#{event}?") and self.send(:"can_#{event}?"))

      self.class.class_variable_get(:@@__specs__).each do |spc|
        self.instance_variable_get(:"@#{spc.name}_statement").publish(event, orig, args)
      end

      true
    end
  end
end