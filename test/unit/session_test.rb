require_relative "../test_helper.rb"

describe Session do
  let(:deck) { Deck.read_from_csv("alphabet") }
  let(:session) { Session.new(deck_id: "alphabet") }

  describe "::new" do
    it "should set a secure random uuid as id by default" do
      SecureRandom.stubs(:uuid).returns("deadbeef42")
      Session.new(deck_id: "alphabet")
      assert_equal "deadbeef42", session.id
    end

    it "should use the given id if set" do
      session = Session.new(id: "foo", deck_id: "alphabet")
      assert_equal "foo", session.id
    end
  end

  describe "::load" do
    before do
      @tempfile = Tempfile.new(["session", ".yml"])
      Session.stubs(:directory).returns(Pathname.new(File.dirname(@tempfile.path)))
    end

    it "should load a session from disk" do
      id = File.basename(@tempfile.path, ".yml")
      data = {
        id: id,
        deck_id: "alphabet",
        answers: [true, nil, true]
      }
      @tempfile.write(data.to_yaml)
      @tempfile.close
      session = Session.load(id)
      assert_equal id, session.id
      assert_equal data[:deck_id], session.deck_id
      assert_equal data[:answers], session.answers
    end

    it "should raise a NotFound error if the file could not be found" do
      assert_raises(Session::NotFound) { Session.load("foobarius") }
    end
  end

  describe "#save" do
    before do
      @tempfile = Tempfile.new(["session", ".yml"])
      Session.stubs(:directory).returns(Pathname.new(File.dirname(@tempfile.path)))
    end

    it "should persist a session to disk" do
      session.answer(0)
      session.save
      expected = {
        id: session.id,
        deck_id: session.deck_id,
        answers: [true]
      }
      actual = YAML.load_file(Session.directory.join("#{session.id}.yml"))
      assert_equal expected, actual
    end

    it "should create directories as needed" do
      FileUtils.rm_rf(Session.directory)
      session.save
      assert File.exists?(Session.directory.join("#{session.id}.yml"))
    end
  end

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

