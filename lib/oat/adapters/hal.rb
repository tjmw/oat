# http://stateless.co/hal_specification.html
require "oat/data_store"

module Oat
  module Adapters
    class HAL < Oat::Adapter
      def initialize(serializer)
        @serializer = serializer
        @data_store = DataStore.new
      end

      def to_hash
        hash = {}
        hash = hash.merge(data_store.properties) if data_store.properties
        hash[:_links] = data_store.links if data_store.links
        hash[:_embedded] = data_store.entities if data_store.entities
        hash
      end

      def link(rel, opts = {})
        data_store.add_link(rel, opts)
      end

      def properties(&block)
        data_store.add_properties(yield_props(&block))
      end

      def property(key, value)
        data_store.add_property(key, value)
      end

      alias_method :meta, :property

      def rel(rels)
        # no-op to maintain interface compatibility with the Siren adapter
      end

      def entity(name, obj, serializer_class = nil, context_options = {}, &block)
        entity_serializer = serializer_from_block_or_class(obj, serializer_class, context_options, &block)
        data_store.add_entity(entity_name(name), entity_serializer ? entity_serializer.to_hash : nil)
      end

      def entities(name, collection, serializer_class = nil, context_options = {}, &block)
        data_store.add_entity(
          entity_name(name), 
          collection.map do |obj|
            entity_serializer = serializer_from_block_or_class(obj, serializer_class, context_options, &block)
            entity_serializer ? entity_serializer.to_hash : nil
          end
        )
      end
      alias_method :collection, :entities

      private

      attr_reader :data_store

      def entity_name(name)
        # entity name may be an array, but HAL only uses the first
        name.respond_to?(:first) ? name.first : name
      end
    end
  end
end
