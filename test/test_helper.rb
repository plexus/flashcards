ENV["RACK_ENV"] = "test"
require "minitest/autorun"
require "rack/test"
require "capybara/dsl"
require "mocha/mini_test"

require_relative "../app.rb"

class MiniTest::Spec
  include Rack::Test::Methods
  include Capybara::DSL

  Capybara.app = Sinatra::Application

  def app
    Sinatra::Application
  end

  def teardown
    Capybara.reset_session!
  end

  def reset_storage
    Session.directory.rmtree if Session.directory.directory?
  end

  def assert_selector(expression, **options)
    page.assert_selector(:css, expression, options)
  rescue Capybara::ExpectationNotMet => e
    assert false, e.message
  end
end

