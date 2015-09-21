ENV["RACK_ENV"] = "test"
require "minitest/autorun"
require "rack/test"
require "mocha/mini_test"

require_relative "../app.rb"

class MiniTest::Spec
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

