require_relative "app"

run Rack::URLMap.new({
  "/" => Public,
  "/p" => Protected
})
