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

    def self.included(base)
      base.extend  Switcher::ClassMethods
      base.extend  Switcher::Object::Initializer

      base.class_eval do
        include Switcher
      end
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