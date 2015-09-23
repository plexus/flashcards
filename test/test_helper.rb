ENV["RACK_ENV"] = "test"
require "minitest/autorun"
require "rack/test"
require "capybara/dsl"
require "mocha/mini_test"
require "timecop"

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

  def assert_starts_with(value, object)
    head = object[0..value.size - 1]
    assert head == value, "expected #{object} to start with #{value}"
  end

  def assert_ends_with(value, object)
    from = object.size - value.size
    tail = object[from..object.size]
    assert tail == value, "expected #{object} to end with #{value}"
  end
end

