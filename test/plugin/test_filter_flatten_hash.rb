require 'helper'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_flatten_hash'

class FlattenHashFilterTest < Test::Unit::TestCase

  BASE_CONFIG = %[
    type flatten_hash
  ]
  CONFIG = BASE_CONFIG + %[
    add_tag_prefix flattened
  ]

  def setup
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  def create_driver(conf = '')
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::FlattenHashFilter).configure(conf, syntax: :v1)
  end

  def test_flatten_record
    d = create_driver
    es = Fluent::MultiEventStream.new
    now = Fluent::Engine.now

    d.run(default_tag: 'test') do
      d.feed({'message' => {'foo' => 'bar'}})
      d.feed({"message" => {'foo' => 'bar', 'hoge' => 'fuga'}})
      d.feed({"message" => {'nest' => {'foo' => 'bar'}}})
      d.feed({"message" => {'nest' => {'nest' => {'foo' => 'bar'}}}})
      d.feed({"message" => {'array' => ['foo', 'bar']}})
      d.feed({"message" => {'array' => [{'foo' => 'bar'}, {'hoge' => 'fuga'}]}})
    end

    assert_equal [
      {"message.foo" => "bar"},
      {"message.foo" => "bar", "message.hoge" => "fuga"},
      {"message.nest.foo" => "bar"},
      {"message.nest.nest.foo" => "bar"},
      {"message.array.0" => "foo", "message.array.1" => "bar"},
      {"message.array.0.foo" => "bar", "message.array.1.hoge" => "fuga"},
    ], d.filtered.map{|x| x[1]}
  end

  def test_separator
    d = create_driver CONFIG + %[separator /]

    d.run(default_tag: 'test') do
      d.feed({"message" => {'nest' => {'foo' => 'bar'}}})
    end
    assert_equal [
      {"message/nest/foo" => "bar"},
    ], d.filtered.map{|x| x[1]}
  end
end
