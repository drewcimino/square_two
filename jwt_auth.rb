require 'jwt'

module Authentication
  ENTITY_LIST = { drew: :cimino }.freeze

  class JwtAuth
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        token           = env.fetch('HTTP_AUTHORIZATION', '').sub(/\A\s*Bearer:\s*/i, '')
        payload, header = JWT.decode(token, ENV['JWT_SECRET'], true, { algorithm: ENV['JWT_ALGORITHM'], iss: ENV['JWT_ISSUER'] })

        @app.call env.merge('user' => payload['user'])
      rescue JWT::DecodeError
        [401, { 'Content-Type' => 'text/plain' }, ['{"error":"A token must be passed."}']]
      rescue JWT::ExpiredSignature
        [403, { 'Content-Type' => 'text/plain' }, ['{"error":"The token has expired.']]
      rescue JWT::InvalidIssuerError
        [403, { 'Content-Type' => 'text/plain' }, ['{"error":"The token does not have a valid issuer.']]
      rescue JWT::InvalidIatError
        [403, { 'Content-Type' => 'text/plain' }, ['{"error":"The token does not have a valid "issued at" time.']]
      end
    end
  end

  class Token < Sinatra::Base
    post '/' do
      if params[:username] && params[:password] && Authentication::ENTITY_LIST[params[:username].to_sym] == params[:password].to_sym
        content_type :json

        { token: token(params[:username].to_s) }.to_json
      else
        halt 401
      end
    end

    private

    def token(username)
      JWT.encode payload(username), ENV['JWT_SECRET'], 'HS256'
    end

    def payload(username)
      {
        exp: Time.now.to_i + 60 * 60 * ENV['JWT_EXP_HOURS'].to_i,
        iat: Time.now.to_i,
        iss: ENV['JWT_ISSUER'],
        user: {
          username: username
        }
      }
    end
  end
end
