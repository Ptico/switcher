require "switcher/version"
require 'switcher/spec'
require 'switcher/statement'
require 'switcher/adapters/object'
require 'switcher/adapters/active_record'

module Switcher
  module ClassMethods
    def switcher(name, options={}, &block)
      self.class_variable_defined?(:@@__specs__) or self.class_variable_set(:@@__specs__, [])

      spec = Spec.new(name, options)
      spec.instance_eval(&block)

      self.class_variable_get(:@@__specs__) << spec

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

      switcher_pre_initialize(self, events)
    end
  end
end