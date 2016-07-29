require 'dashing'

configure do
  set :auth_token, 'dasfkjlesah9sdfssdfgggggg34th3vhglxwht4xwgrtcohgsd'
end

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['shop', ENV['BASIC_AUTH_PASSWORD']]
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
