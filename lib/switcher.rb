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

      switcher_pre_initialize(self, spec)
    end
  end
end