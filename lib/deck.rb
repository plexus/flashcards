require "csv"

class Deck

  def self.read_from_csv(id)
    data = CSV.read(Root.join("data", "decks", "#{id}.csv"), return_headers: false)
    data.shift
    cards = data.each_with_index.map { |(back, front), id| Card.new(id, front, back) }
    new(id, cards)
  end

  attr_reader :id, :cards

  def initialize(id, cards)
    @id, @cards = id, cards
  end

end

