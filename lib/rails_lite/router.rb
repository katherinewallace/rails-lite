class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    if pattern.is_a?(Regexp)
      @pattern = pattern
    else
      @pattern = Regexp.new("^#{pattern}$")
    end
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end


  def matches?(req)
    self.pattern.match(req.path) && 
    (@http_method == req.request_method.downcase.to_sym)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    match = self.pattern.match(req.path)
    params = {}
    match.names.each_with_index do |name, i|
      params[name.to_sym] = match.captures[i]
    end
    @controller_class.new(req, res, params).invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end


  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end


  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end


  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end
    nil
  end


  def run(req, res)
    
    route = self.match(req)
    if route
      route.run(req, res)
    else
      res.status = 404
    end
  end
end
