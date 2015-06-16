module Fluent
  class FlattenHashOutput < Output
    include Fluent::HandleTagNameMixin
    Fluent::Plugin.register_output('flatten_hash', self)

    require_relative 'flatten_hash_util'
    include FlattenHashUtil

    config_param :tag, :string, :default => nil
    config_param :separator, :string, :default => '.'

    def initialize
      super
    end

    def configure(conf)
      super
      if (!@tag &&
          !remove_tag_prefix &&
          !remove_tag_suffix &&
          !add_tag_prefix &&
          !add_tag_suffix )
        raise ConfigError, "out_flatten_hash: No tag parameters are set"
      end
    end

    def emit(tag, es, chain)
      tag = @tag || tag
      es.each do |time, record|
        record = flatten_record(record, [])
        t = tag.dup
        filter_record(t, time, record)
        Engine.emit(t, time, record)
      end
      chain.next
    end
  end
end
