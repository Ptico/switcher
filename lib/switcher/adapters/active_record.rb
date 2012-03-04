module Switcher
  module ActiveRecord

    module Initializer
    end

    module ClassMethods
      def switcher_pre_initialize(inst, spec)
        inst.class_eval do
          spec_name = spec.name

          define_method(:"#{spec_name}_spec") { spec }
          define_method(:"#{spec_name}_prev") { self.instance_variable_get(:"@#{spec_name}_statement").state_prev }

          define_method(:"#{spec_name}") { self.instance_variable_get(:"@#{spec_name}_statement").state_current }

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
              switch_from(nil, event_name, *args)
            end
          end

        end
      end
    end

    def self.included(base)
      base.extend Switcher::ClassMethods
      base.extend Switcher::ActiveRecord::ClassMethods

      base.class_eval do
        after_initialize do
          self.class.class_variable_get(:@@__specs__).each do |spec|
            spec_name     = spec.name
            state_current = read_attribute(spec_name)
            state_prev    = (has_attribute?("#{spec_name}_prev") ? read_attribute("#{spec_name}_prev") : nil)

            self.instance_variable_set(:"@#{spec_name}_statement", Statement.new(self, spec, state_current, state_prev))
          end
        end
      end
    end

    def switch(event, *args)
      switch_from(self.class, event, *args)
    end

    def switch_from(orig, event, *args)
      self.class.class_variable_get(:@@__specs__).each do |spc|
        spc_name = spc.name

        self.instance_variable_get(:"@#{spc_name}_statement").publish(event, orig, args)

        write_attribute(spc_name, self.send(:"#{spc_name}"))
        if has_attribute?("#{spc_name}_prev")
          write_attribute("#{spc_name}_prev", self.send(:"#{spc_name}_prev"))
        end
      end
    end

  end
end