require 'helper'
require 'fluent/plugin/filter_flatten_hash'

class FlattenHashFilterTest < Test::Unit::TestCase
  include Fluent

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
    Test::FilterTestDriver.new(FlattenHashFilter).configure(conf, true)
  end

  def test_flatten_record
    d = create_driver
    es = Fluent::MultiEventStream.new
    now = Fluent::Engine.now

    d.run do
      d.emit({'message' => {'foo' => 'bar'}})
      d.emit({"message" => {'foo' => 'bar', 'hoge' => 'fuga'}})
      d.emit({"message" => {'nest' => {'foo' => 'bar'}}})
      d.emit({"message" => {'nest' => {'nest' => {'foo' => 'bar'}}}})
      d.emit({"message" => {'array' => ['foo', 'bar']}})
      d.emit({"message" => {'array' => [{'foo' => 'bar'}, {'hoge' => 'fuga'}]}})
    end

    assert_equal [
      {"message.foo" => "bar"},
      {"message.foo" => "bar", "message.hoge" => "fuga"},
      {"message.nest.foo" => "bar"},
      {"message.nest.nest.foo" => "bar"},
      {"message.array.0" => "foo", "message.array.1" => "bar"},
      {"message.array.0.foo" => "bar", "message.array.1.hoge" => "fuga"},
    ], d.filtered_as_array.map{|x| x[2]}
  end

  def test_separator
    d = create_driver CONFIG + %[separator /]

    d.run do
      d.emit({"message" => {'nest' => {'foo' => 'bar'}}})
    end
    assert_equal [
      {"message/nest/foo" => "bar"},
    ], d.filtered_as_array.map{|x| x[2]}
  end
end
