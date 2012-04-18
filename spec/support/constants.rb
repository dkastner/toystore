module Support
  module Constants
    extend ActiveSupport::Concern

    module ClassMethods
      def uses_constants(*constants)
        before { create_constants(*constants) }
      end
    end

    def create_constants(*constants)
      constants.each { |constant| create_constant(constant) }
    end

    def remove_constants(*constants)
      constants.each { |constant| remove_constant(constant) }
    end

    def create_constant(constant, superclass=nil)
      remove_constant(constant)
      Kernel.const_set(constant, Model(constant, superclass))
    end

    def remove_constant(constant)
      Kernel.send(:remove_const, constant) if Kernel.const_defined?(constant)
    end

    def Model(name=nil, superclass=nil)
      if superclass.nil?
        Class.new
      else
        Class.new(superclass)
      end.tap do |model|
        model.class_eval """
          def self.name; '#{name}' end
          def self.to_s; '#{name}' end
        """ if name
        model.send(:include, Toy::Store)
      end
    end
  end
end
