require 'helper'
require 'fluent/test/driver/output'
require 'fluent/plugin/out_flatten_hash'

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

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::FlattenHashOutput).configure(conf)
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
    ], d.events.map{|e| e[2]}
  end

  def test_separator
    d = create_driver CONFIG + %[separator /]

    d.run(default_tag: 'test') do
      d.feed({"message" => {'nest' => {'foo' => 'bar'}}})
    end

    assert_equal [
      {"message/nest/foo" => "bar"},
    ], d.events.map{|e| e[2]}
  end

  def test_emit_with_add_tag_prefix
    d = create_driver BASE_CONFIG + %[
      add_tag_prefix flattened.
    ]
    d.run(default_tag: 'test') do
      d.feed({'message' => {'foo' => 'bar'}})
      d.feed({'message' => {'foo' => 'bar'}})
      d.feed({'message' => {'foo' => 'bar'}})
    end
    events = d.events
    events.each do |e|
      assert_equal 'flattened.test', e[0]
      assert_equal 'bar', e[2]["message.foo"]
    end
    assert_equal 3, events.count
  end

  def test_emit_with_remove_tag_prefix
    tag = 'prefix.prefix.test'
    d = create_driver BASE_CONFIG + %[
      remove_tag_prefix prefix.
    ]
    d.run(default_tag: tag) do
      d.feed({'message' => {'foo' => 'bar'}})
      d.feed({'message' => {'foo' => 'bar'}})
      d.feed({'message' => {'foo' => 'bar'}})
    end
    events = d.events
    events.each do |e|
      assert_equal 'prefix.test', e[0]
      assert_equal 'bar', e[2]["message.foo"]
    end
    assert_equal 3, events.count
  end
end
