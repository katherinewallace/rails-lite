require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @already_rendered = false
    @params = Params.new(req, route_params)
  end

  def render_content(content, type)
    raise "already rendered" if already_rendered?
    @res.content_type = type
    @res.body = content
    self.session.store_session(@res)
    @already_rendered = true
  end

  def already_rendered?
    @already_rendered
  end

  def redirect_to(url)
    raise "already rendered" if already_rendered?
    @res.header["location"] = url
    @res.status = 302
    self.session.store_session(@res)
    @already_rendered = true
  end

  def render(template_name)
    contents = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    template = ERB.new(contents).result(binding)
    render_content(template, "text/html")
  end

  def session
    @session ||= Session.new(req)
  end

  def invoke_action(name)
    self.send(name.to_sym)
    unless already_rendered?
      render(name.to_sym)
    end
  end
end
