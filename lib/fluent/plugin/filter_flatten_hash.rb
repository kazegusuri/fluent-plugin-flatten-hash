require 'fluent/plugin/filter'

module Fluent::Plugin
  class FlattenHashFilter < Filter
    Fluent::Plugin.register_filter('flatten_hash', self)

    require_relative 'flatten_hash_util'
    include Fluent::FlattenHashUtil

    config_param :separator, :string, default: '.'
    config_param :flatten_array, :bool, default: true

    def configure(conf)
      super
    end

    def filter(tag, time, record)
      flatten_record(record, [])
    end
  end
end
