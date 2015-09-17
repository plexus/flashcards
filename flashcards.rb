require "csv"
require "io/console"

cards = CSV.read("hiragana.csv", headers: true).to_a

puts "Welcome to flashcards. Press any™ key to continue, Exit using CTRL+C\n"
pile = []
loop do
  pile = cards.shuffle if pile.empty?
  romaji, hiragana = pile.pop
  print "\r\n #{hiragana}"
  exit if STDIN.getch == "\u0003"
  puts " #{romaji}"
  system("say #{hiragana} &") if ENV["SPEAK"]
end

