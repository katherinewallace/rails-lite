require 'json'
require 'webrick'

class Session

  def initialize(req)
    cookie = req.cookies.find { |c| c.name == '_rails_lite_app' }
    cookie ? @cookie = JSON.parse(cookie.value) : @cookie = {} 
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @cookie.to_json)
  end
end
