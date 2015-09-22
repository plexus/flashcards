require_relative "../test_helper.rb"

describe Deck do

  describe Deck::Card do

    describe "#==" do
      it "should compare against id" do
        assert Deck::Card.new(0, "a", "A") == Deck::Card.new(0, "a", "A")
        assert Deck::Card.new(1, "a", "A") != Deck::Card.new(0, "a", "A")
      end

      it "should compare against front" do
        assert Deck::Card.new(0, "a", "A") == Deck::Card.new(0, "a", "A")
        assert Deck::Card.new(0, "b", "A") != Deck::Card.new(0, "a", "A")
      end

      it "should compare against back" do
        assert Deck::Card.new(0, "a", "A") == Deck::Card.new(0, "a", "A")
        assert Deck::Card.new(0, "a", "B") != Deck::Card.new(0, "a", "A")
      end

      it "should compare wether the give object is a Deck::Card" do
        assert Deck::Card.new(0, "a", "A") == Deck::Card.new(0, "a", "A")
        assert Deck::Card.new(0, "a", "A") != stub(id: 0, front: "a", back: "A")
      end
    end

  end

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

