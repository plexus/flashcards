require_relative "../test_helper.rb"

describe Session do
  let(:deck) { Deck.new("alphabet") }
  let(:session) { Session.new(deck_id: "alphabet") }

  describe "#deck" do
    it "should return the deck referenced by deck_id" do
      assert_instance_of Deck, session.deck
      assert_equal "alphabet", session.deck.id
    end

    it "should memoize the deck" do
      deck = session.deck
      assert_equal deck.object_id, session.deck.object_id
    end
  end

  describe "#pile" do
    it "should return all cards from the deck" do
      assert_equal deck.cards, session.pile
    end

    it "should exclude answered cards" do
      answers = []
      answers[10] = true
      answers[15] = true
      session = Session.new(deck_id: "alphabet", answers: answers)
      expected = deck.cards
      expected.delete_at(15)
      expected.delete_at(10)
      assert_equal expected, session.pile
    end

    it "should be empty if all cards are answered" do
      answers = deck.cards.map { true }
      session = Session.new(deck_id: "alphabet", answers: answers)
      assert_empty session.pile
    end
  end

  describe "#answer" do
    it "should mark a card as answered by id" do
      deck.cards.each do |card|
        session.answer(card.id)
      end
      assert_empty session.pile
    end

    it "should coerce string ids" do
      deck.cards.each do |card|
        session.answer(card.id.to_s)
      end
      assert_empty session.pile
    end

    it "should ignore invalid ids" do
      session.answer("")
      session.answer(nil)
      session.answer(-1)
      session.answer(deck.cards.size + 1)
      assert_equal deck.cards, session.pile
      assert_empty session.answers
    end
  end

end

