require "csv"

class Deck

  class Card

    attr_reader :id, :front, :back

    def initialize(id, front, back)
      @id, @front, @back = id, front, back
    end

    def ==(other)
      other.is_a?(Card) &&
        other.id == id &&
        other.front == front &&
        other.back == back
    end

  end

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

