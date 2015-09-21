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

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def cards
    @cards ||= begin
      data = read_csv
      data.shift
      data.each_with_index.map { |(back, front), id| Card.new(id, front, back) }
    end
  end

  private

  def read_csv
    CSV.read(Root.join("data", "decks", "#{id}.csv"), return_headers: false)
  end

end

