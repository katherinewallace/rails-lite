require 'uri'
require 'debugger'
require_relative 'hash_method'

class Params
  include HashHelper

  def initialize(req, route_params = {})
    @params = route_params
    if req.query_string
      @params.merge!parse_www_encoded_form(req.query_string)
    end
    if req.body
      @params.merge!(parse_www_encoded_form(req.body))
    end
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  def parse_www_encoded_form(www_encoded_form)
    array = URI.decode_www_form(www_encoded_form)
    params = {}
    array.each do |keys, value|
      keys = parse_key(keys).reverse
      subparams = keys.inject(value) { |x, y| { y => x} }
      params = hash_deep_merge(params, subparams)
    end
    params
  end

  def parse_key(key)
    key.gsub("]", "").split("[")
  end
  
  private
  
  def hash_deep_merge
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    first.merge(second, &merger)
  end
  
end
