module Toy
  class Attribute
    attr_reader :model, :name, :type, :options

    def initialize(model, name, type, options={})
      options.assert_valid_keys(:default, :virtual, :abbr)

      @model, @name, @type, @options = model, name.to_s, type, options
      @virtual = options.fetch(:virtual, false)

      if abbr?
        options[:abbr] = abbr.to_s
        model.alias_attribute(abbr, name)
      end

      model.attributes[name.to_s] = self
      model.define_attribute_method name.to_sym
    end

    def from_store(value)
      value = default if default? && value.nil?
      type.from_store(value, self)
    end

    def to_store(value)
      value = default if default? && value.nil?
      type.to_store(value, self)
    end

    def default
      if options.key?(:default)
        default = options[:default]
        if default.respond_to?(:call)
          backwards_compatible_call(default)
        else
          default
        end
      else
        type.respond_to?(:store_default) ? type.store_default : nil
      end
    end

    def default?
      options.key?(:default) || type.respond_to?(:store_default)
    end

    def virtual?
      @virtual
    end

    def persisted?
      !virtual?
    end

    def abbr?
      options.key?(:abbr)
    end

    def abbr
      options[:abbr]
    end

    def persisted_name
      abbr? ? abbr : name
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?

    private

    def backwards_compatible_call(block)
      if block.arity == 1
        block.call(model)
      else
        block.call
      end
    end
  end
end
