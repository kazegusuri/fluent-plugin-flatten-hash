require 'helper'

class FlattenHashOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  BASE_CONFIG = %[
    type flatten_hash
  ]
  CONFIG = BASE_CONFIG + %[
    add_tag_prefix flattened
  ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::FlattenHashOutput, tag).configure(conf)
  end

  def test_configure
    assert_raise(Fluent::ConfigError) {
      create_driver(BASE_CONFIG)
    }
    assert_nothing_raised(Fluent::ConfigError) {
      create_driver(BASE_CONFIG + %[
        tag hoge
      ])
    }
    assert_nothing_raised(Fluent::ConfigError) {
      create_driver(BASE_CONFIG + %[
        add_tag_prefix hoge
      ])
    }
    assert_nothing_raised(Fluent::ConfigError) {
      create_driver(BASE_CONFIG + %[
        add_tag_suffix hoge
      ])
    }
    assert_nothing_raised(Fluent::ConfigError) {
      create_driver(BASE_CONFIG + %[
        remove_tag_prefix hoge
      ])
    }
    assert_nothing_raised(Fluent::ConfigError) {
      create_driver(BASE_CONFIG + %[
        remove_tag_suffix hoge
      ])
    }
  end

  def test_flatten_record
    d = create_driver

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
    ], d.records
  end

  def test_separator
    d = create_driver CONFIG + %[separator /]

    d.run do
      d.emit({"message" => {'nest' => {'foo' => 'bar'}}})
    end

    assert_equal [
      {"message/nest/foo" => "bar"},
    ], d.records
  end

end
