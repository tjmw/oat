# https://github.com/kevinswiber/siren
require "oat/data_store"
require "byebug"

module Oat
  module Adapters
    class Siren < Oat::Adapter

      def initialize(*args)
        super
        @data_store = DataStore.new
        data[:entities] = []
        data[:actions] = []
      end

      def to_hash
        hash = super

        hash[:properties] = data_store.properties if data_store.properties
        hash[:rel] = data_store.rel if data_store.rel
        hash[:class] = data_store.type if data_store.type

        if data_store.links
          hash[:links] = data_store.links.map {|rel, opts|
            { rel: [rel].flatten }.merge(opts)
          }
        end

        hash
      end

      # Sub-Entities have a required rel attribute
      # https://github.com/kevinswiber/siren#rel
      def rel(rels)
        # rel must be an array.
        data_store.add_rel Array(rels)
      end

      def type(*types)
        data_store.add_type(types)
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

      def entity(name, obj, serializer_class = nil, context_options = {}, &block)
        ent = serializer_from_block_or_class(obj, serializer_class, context_options, &block)
        if ent
          # use the name as the sub-entities rel to the parent resource.
          ent.rel(name)
          ent_hash = ent.to_hash

          unless data[:entities].include? ent_hash
            data[:entities] << ent_hash
          end
        end
      end

      def entities(name, collection, serializer_class = nil, context_options = {}, &block)
        collection.each do |obj|
          entity name, obj, serializer_class, context_options, &block
        end
      end

      alias_method :collection, :entities

      def action(name, &block)
        action = Action.new(name)
        block.call(action)

        data[:actions] << action.data
      end

      class Action
        attr_reader :data

        def initialize(name)
          @data = { :name => name, :class => [], :fields => [] }
        end

        def class(value)
          data[:class] << value
        end

        def field(name, &block)
          field = Field.new(name)
          block.call(field)

          data[:fields] << field.data
        end

        %w(href method title type).each do |attribute|
          define_method(attribute) do |value|
            data[attribute.to_sym] = value
          end
        end

        class Field
          attr_reader :data

          def initialize(name)
            @data = { :name => name }
          end

          %w(type value title).each do |attribute|
            define_method(attribute) do |value|
              data[attribute.to_sym] = value
            end
          end
        end
      end

      private

      attr_reader :data_store
    end
  end
end
