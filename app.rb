require 'sinatra/base'
require 'json'

require_relative 'jwt_auth'
require_relative 'settings'

class App < Sinatra::Base
  use Authentication::JwtAuth

  get '/' do
    content_type :json

    { message: 'Hello, World!' }.to_json
  end
end
