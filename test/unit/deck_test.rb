require_relative "../test_helper.rb"

describe Deck do

  let(:deck) { Deck.new("hiragana") }

  describe "#cards" do
    it "should load all rows from the named csv file" do
      rows = File.open(Root.join("data", "decks", "hiragana.csv"), "r").readlines.count - 1
      assert_equal rows, deck.cards.size
    end

    it "should initialize a card for each row of the named csv file" do
      cards = deck.cards
      assert_equal Deck::Card, cards.map(&:class).uniq.first
      assert_equal Deck::Card.new(0, "あ", "a"), cards.first
    end

    it "should memoize cards" do
      cards = deck.cards
      assert_equal cards.object_id, deck.cards.object_id
    end
  end

end

