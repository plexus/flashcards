ENV["RACK_ENV"] ||= "development"
require "bundler"
Bundler.require
require "tilt/erb" # tilt issues an annoying warning about thread-safety

Root = Pathname.new(File.dirname(__FILE__))
$LOAD_PATH.unshift(Root.join("lib"))
Dir.glob("lib/**/*.rb").sort.each { |file| require_relative file }

get "/" do
  session = Session.new(deck_id: ENV["DECK"] || "hiragana")
  session.save
  redirect to("/sessions/#{session.id}")
end

get "/sessions/:session_id" do |session_id|
  @session = Session.load(session_id)
  @card = @session.next_card
  erb :session
end

post "/sessions/:session_id/cards/:card_id" do |session_id, card_id|
  session = Session.load(session_id)
  session.answer(card_id)
  session.save
  redirect to("/sessions/#{session_id}")
end

post "/restart" do
  redirect to("/")
end

