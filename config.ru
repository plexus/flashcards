require_relative 'app.rb'

run FlashcardApp.new(ENV.fetch('DECK', 'hiragana'))
