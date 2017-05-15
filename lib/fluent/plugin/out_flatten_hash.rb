require 'fluent/plugin/output'

module Fluent::Plugin
  class FlattenHashOutput < Output
    include Fluent::HandleTagNameMixin
    Fluent::Plugin.register_output('flatten_hash', self)

    helpers :event_emitter

    require_relative 'flatten_hash_util'
    include Fluent::FlattenHashUtil

    config_param :tag, :string, :default => nil
    config_param :separator, :string, :default => '.'
    config_param :flatten_array, :bool, :default => true

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
        raise Fluent::ConfigError, "out_flatten_hash: No tag parameters are set"
      end
    end

    def multi_workers_ready?
      true
    end

    def process(tag, es)
      tag = @tag || tag
      es.each do |time, record|
        record = flatten_record(record, [])
        t = tag.dup
        filter_record(t, time, record)
        router.emit(t, time, record)
      end
    end
  end
end
