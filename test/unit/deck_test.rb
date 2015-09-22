require_relative "../test_helper.rb"

describe Deck do


  let(:deck) { Deck.read_from_csv("hiragana") }

  describe "::read_from_csv" do
    it "should load all rows from the named csv file" do
      rows = File.open(Root.join("data", "decks", "hiragana.csv"), "r").readlines.count - 1
      assert_equal rows, deck.cards.size
    end

    it "should initialize a card for each row of the named csv file" do
      cards = deck.cards
      assert_equal Deck::Card, cards.map(&:class).uniq.first
      assert_equal Deck::Card.new(0, "あ", "a"), cards.first
    end
  end

end

