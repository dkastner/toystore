module Toy
  module Attributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    included do
      include Identity
      attribute_method_suffix('=', '?')
    end

    module ClassMethods
      def attributes
        @attributes ||= {}
      end

      def defaulted_attributes
        attributes.values.select(&:default?)
      end

      def attribute(key, type, options = {})
        Attribute.new(self, key, type, options)
      end

      def attribute?(key)
        attributes.has_key?(key.to_s)
      end
    end

    def initialize(attrs={})
      initialize_attributes_with_defaults
      self.attributes = attrs
      write_attribute :id, self.class.next_key(self) unless id?
    end

    def id
      read_attribute(:id)
    end

    def attributes
      @attributes
    end

    def persisted_attributes
      {}.tap do |attrs|
        self.class.attributes.each do |name, attribute|
          next if attribute.virtual?
          attrs[attribute.persisted_name] = attribute.to_store(read_attribute(attribute.name))
        end
      end
    end

    def attributes=(attrs, *)
      return if attrs.nil?
      attrs.each do |key, value|
        if attribute_method?(key)
          write_attribute(key, value)
        elsif respond_to?("#{key}=")
          send("#{key}=", value)
        end
      end
    end

    def [](key)
      read_attribute(key)
    end

    def []=(key, value)
      write_attribute(key, value)
    end

    private

    def read_attribute(key)
      @attributes ||= {}
      @attributes[key.to_s]
    end

    def write_attribute(key, value)
      @attributes[key.to_s] = attribute_definition(key).try(:from_store, value)
    end

    def attribute_definition(key)
      self.class.attributes[key.to_s]
    end

    def attribute_method?(key)
      self.class.attribute?(key)
    end

    def attribute(key)
      read_attribute(key)
    end

    def attribute=(key, value)
      write_attribute(key, value)
    end

    def attribute?(key)
      read_attribute(key).present?
    end

    def initialize_attributes_with_defaults
      @attributes ||= {}
      self.class.defaulted_attributes.each do |attribute|
        @attributes[attribute.name.to_s] = attribute.default
      end
    end
  end
end