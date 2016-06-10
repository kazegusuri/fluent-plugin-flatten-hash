require 'helper'
require 'fluent/plugin/filter_flatten_hash'

class FlattenHashIndexArrayFilterTest < Test::Unit::TestCase
  include Fluent

  BASE_CONFIG = %[
    type flatten_hash
  ]
  CONFIG = BASE_CONFIG + %[
    add_tag_prefix flattened
    index_array false
  ]

  def setup
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  def create_driver(conf = '')
    Test::FilterTestDriver.new(FlattenHashFilter).configure(conf, true)
  end

  def test_flatten_record_index_array_false
    d = create_driver CONFIG
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
      {"message.array"=>["foo", "bar"]},
      {"message.array"=>[{"foo"=>"bar"}, {"hoge"=>"fuga"}]},
    ], d.filtered_as_array.map{|x| x[2]}
  end
end
