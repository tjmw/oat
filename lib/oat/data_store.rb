module Oat
  class DataStore
    def initialize
      @data = Hash.new {|h,k| h[k] = {}}
    end

    def links
      data[:_links]
    end

    def add_link(rel, opts = {})
      if opts.is_a?(Array)
        data[:_links][rel] = opts.select { |link_obj| link_obj.include?(:href) }
      else
        data[:_links][rel] = opts if opts[:href]
      end
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
      data[:_entities][name] = obj
    end

    private

    attr_reader :data
  end
end
