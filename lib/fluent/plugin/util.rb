module Fluent
  module FlattenHashUtil
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
