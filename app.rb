require "bundler"
Bundler.require

Root = Pathname.new(File.dirname(__FILE__))
$LOAD_PATH.unshift(Root.join("lib"))
Dir.glob("lib/**/*.rb").sort.each { |file| require_relative file }

class FlashcardApp < Sinatra::Base
  def initialize(deck_id)
    super(nil) # don't care about running as middleware
    @deck_id = deck_id
  end

  helpers do
    def restart
      $session = Session.new(deck_id: @deck_id)
    end
  end

  get "/" do
    restart unless $session
    @card = $session.next_card
    erb :session
  end

  post "/session/cards/:card_id" do |card_id|
    $session.answer(card_id)
    redirect to("/")
  end

  post "/restart" do
    restart
    redirect to("/")
  end
end
