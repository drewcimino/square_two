require File.expand_path '../app.rb', __FILE__

run Rack::URLMap.new({
  '/'      => App,
  '/token' => Authentication::Token
})
