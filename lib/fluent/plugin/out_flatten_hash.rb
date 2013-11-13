module Fluent
  class FlattenHashOutput < Output
    include Fluent::HandleTagNameMixin
    Fluent::Plugin.register_output('flatten_hash', self)

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
        tag = tag.dup
        filter_record(tag, time, record)
        Engine.emit(tag, time, record)
      end
      chain.next
    end

    private
    def flatten_record(record, prefix)
      ret = {}
      if record.is_a? Hash
        record.each { |key, value|
          ret.merge! flatten_record(value, prefix + [key.to_s])
        }
      elsif record.is_a? Array
        record.each_with_index { |elem, index|
          ret.merge! flatten_record(elem, prefix + [index.to_s])
        }
      else
        return {prefix.join(@separator) => record}
      end
      ret
    end
  end
end
