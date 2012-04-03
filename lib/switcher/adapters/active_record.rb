module Switcher
  module ActiveRecord
    def self.included(base)
      base.extend Switcher::ClassMethods

      base.class_eval do
        include Switcher

        after_initialize do
          self.class.class_variable_get(:@@__specs__).each do |spec|
            spec_name     = spec.name
            state_current = read_attribute(spec_name)
            state_prev    = (has_attribute?("#{spec_name}_prev") ? read_attribute("#{spec_name}_prev") : nil)

            self.instance_variable_set(:"@#{spec_name}_statement", Statement.new(self, spec, state_current, state_prev))
          end
        end

        before_validation do
          self.class.class_variable_get(:@@__specs__).each do |spc|
            spc_name = spc.name

            current_state = self.instance_variable_get(:"@#{spc.name}_statement").state_current
            write_attribute(spc_name, current_state)
          end
        end
      end
    end

    def switch_from(orig, event, *args)
      return false unless (self.respond_to?(:"can_#{event}?") and self.send(:"can_#{event}?"))

      self.class.class_variable_get(:@@__specs__).each do |spc|
        spc_name = spc.name

        self.instance_variable_get(:"@#{spc_name}_statement").publish(event, orig, args)

        write_attribute(spc_name, self.send(:"#{spc_name}"))
        if has_attribute?("#{spc_name}_prev")
          write_attribute("#{spc_name}_prev", self.send(:"#{spc_name}_prev"))
        end
      end

      true
    end
  end
end