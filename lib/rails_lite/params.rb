require 'uri'
require 'debugger'
require_relative 'hash_method'

class Params
  include HashHelper
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
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

  # private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
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

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.gsub("]", "").split("[")
  end
  

  
end
