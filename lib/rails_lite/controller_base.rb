require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @already_rendered = false
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "already rendered" if already_rendered?
    @res.content_type = type
    @res.body = content
    self.session.store_session(@res)
    @already_rendered = true
  end

  # helper method to alias @already_rendered
  def already_rendered?
    @already_rendered
  end

  # set the response status code and header
  def redirect_to(url)
    raise "already rendered" if already_rendered?
    @res.header["location"] = url
    @res.status = 302
    self.session.store_session(@res)
    @already_rendered = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    contents = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    template = ERB.new(contents).result(binding)
    render_content(template, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name.to_sym)
    unless already_rendered?
      render(name.to_sym)
    end
  end
end
