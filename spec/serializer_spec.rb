require 'spec_helper'

describe Oat::Serializer do

  before do
    @adapter_class = Class.new(Oat::Adapter) do
      def attributes(&block)
        data[:attributes].merge!(yield_props(&block))
      end

      def attribute(key, value)
        data[:attributes][key] = value
      end

      def link(rel, url)
        data[:links][rel] = url
      end
    end

    @sc = Class.new(Oat::Serializer) do

      schema do
        my_attribute 'Hello'
        attribute :id, item.id
        attributes do |attrs|
          attrs.name item.name
          attrs.age item.age
          attrs.controller_name context[:name]
        end
        link :self, url_for(item.id)
      end

      def url_for(id)
        "http://foo.bar.com/#{id}"
      end

      def my_attribute(value)
        attribute :special, value
      end
    end

    @sc.adapter @adapter_class
  end

  let(:user_class) do
    Struct.new(:name, :age, :id, :friends)
  end

  let(:user1) { user_class.new('Ismael', 35, 1, []) }

  it 'should have a version number' do
    expect(Oat::VERSION).to_not be_nil
  end

  describe "#context" do
    it "is a hash by default" do
      expect(@sc.new(user1).context).to be_a Hash
    end

    it "can be set like an options hash" do
      serializer = @sc.new(user1, :controller => double(:name => "Fancy"))
      expect(serializer.context.fetch(:controller).name).to eq "Fancy"
    end
  end

  describe '#to_hash' do
    it 'builds Hash from item and context with attributes as defined in adapter' do
      serializer = @sc.new(user1, :name => 'some_controller')
      expect(serializer.to_hash.fetch(:attributes)).to include(
        :special => 'Hello',
        :id => user1.id,
        :name => user1.name,
        :age => user1.age,
        :controller_name => 'some_controller'
      )

      expect(serializer.to_hash.fetch(:links)).to include(
        :self => "http://foo.bar.com/#{user1.id}"
      )
    end

    context "when a serializer inherits from another serializer" do
      let(:child_serializer) {
        Class.new(@sc) do
          schema do
            attribute :id_plus_x, "#{item.id}_x"
          end
        end
      }

      it "produces the result of both schema blocks in order" do
        serializer = child_serializer.new(user1, name: "child_controller")

        expect(serializer.to_hash.fetch(:attributes)).to include(
          special: 'Hello',
          id: user1.id,
          id_plus_x: "#{user1.id}_x",
        )
      end

      it "does not affect the parent serializer" do
        serializer = @sc.new(user1, :name => 'some_controller')

        expect(serializer.to_hash.fetch(:attributes)).to_not have_key(:id_plus_x)
      end
    end
  end
end
