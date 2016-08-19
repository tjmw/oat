module Oat
  class DataStore
    def initialize
      @data = {}
    end

    def links
      data[:_links]
    end

    def add_link(rel, opts = {})
      (data[:_links] ||= {})[rel] = opts
    end

    def properties
      data[:_properties]
    end

    def add_property(key, value)
      (data[:_properties] ||= {})[key] = value
    end

    def add_properties(properties)
      properties.each do |k,v|
        add_property(k, v)
      end
    end

    def entities
      data[:_entities]
    end

    def add_entity(name, obj)
      (data[:_entities] ||= {})[name] = obj
    end

    def rel
      data[:_rel]
    end

    def add_rel(rels)
      data[:_rel] = rels
    end

    def type
      data[:_type]
    end

    def add_type(types)
      data[:_type] = types
    end

    private

    attr_reader :data
  end
end
