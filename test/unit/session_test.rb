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
        answers: [Answer.new, nil, Answer.new]
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
      Timecop.freeze do
        session.answer(card_id: 0, flag: "incorrect")
        session.save
        expected = {
          id: session.id,
          deck_id: session.deck_id,
          answers: [Answer.new]
        }
        actual = YAML.load_file(Session.directory.join("#{session.id}.yml"))
        assert_equal expected, actual
      end
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

  describe "#next_card" do
    it "should return the first card of the pile" do
      assert_equal session.next_card, session.pile.first
    end

    it "should return the first card only if it is due to repeat" do
      deck.cards.each { |card| session.answer(card_id: card.id, flag: "correct") }
      first_card = session.pile.first
      answer = session.answers[first_card.id]

      assert_nil session.next_card
      Timecop.freeze(answer.repeat_at) do
        assert_equal first_card, session.next_card
      end
    end
  end

  describe "#pile" do
    it "should return all cards from the deck" do
      assert_equal deck.cards, session.pile
    end

    it "should sort unanswered cards on top" do
      head = deck.cards.last(3).reverse
      answers = (deck.cards - head).map { Answer.new }
      session = Session.new(deck_id: "alphabet", answers: answers)
      assert_starts_with head, session.pile
    end

    it "should sort answered cards to the bottom by their repeat time in ascending order" do
      answers = []
      answers[15] = Answer.new(0, Time.now)  # will repeat in 1 minute
      answers[10] = Answer.new(10, Time.now) # will repeat in 150 minutes
      session = Session.new(deck_id: "alphabet", answers: answers)
      tail = [deck.cards[15], deck.cards[10]]
      assert_ends_with tail, session.pile
    end
  end

  describe "#answers" do
    it "should have nil answers by default" do
      deck.cards.each do |card|
        assert_nil session.answers[card.id]
      end
    end

    it "should only expose a frozen array" do
      # enforces to use Session#answer
      assert_raises { session.answers.pop }
      assert session.answers.frozen?
    end

    it "should freeze all answers" do
      # enforces to use Session#answer
      assert_raises { session.answers.first.answer }
      assert session.answers.all?(&:frozen?)
    end
  end

  describe "#answer" do
    it "should initialize a correct answer on the card id by default" do
      Timecop.freeze do
        answer = Answer.new
        answer.correct
        session.answer(card_id: 15, flag: "correct")
        assert_equal answer, session.answers[15]
      end
    end

    it "should store an incorrect answer on the card id" do
      Timecop.freeze do
        answer = Answer.new
        answer.incorrect
        session.answer(card_id: 15, flag: "incorrect")
        assert_equal answer, session.answers[15]
      end
    end

    it "should increment a correct answer on the card id" do
      answer = Answer.new
      Timecop.freeze(Time.now - 120) do
        answer.correct
        session.answer(card_id: 15, flag: "correct")
      end
      Timecop.freeze do
        answer.correct
        session.answer(card_id: 15, flag: "correct")
        assert_equal answer, session.answers[15]
      end
    end

    it "should coerce string ids" do
      Timecop.freeze do
        answer = Answer.new
        answer.correct
        session.answer(card_id: "15", flag: "correct")
        assert_equal answer, session.answers[15]
      end
    end

    it "should ignore invalid ids" do
      session.answer(card_id: "", flag: "correct")
      session.answer(card_id: nil, flag: "correct")
      session.answer(card_id: -1, flag: "correct")
      session.answer(card_id: deck.cards.size + 1, flag: "correct")
      assert_equal deck.cards, session.pile
      assert_empty session.answers
    end
  end

  describe "#next_card_at" do
    it "should return the current time if the next card has not been answered" do
      Timecop.freeze do
        assert_equal Time.now, session.next_card_at
      end
    end

    it "should return the due time of the next card if it has been answered" do
      Timecop.freeze do
        deck.cards.each { |card| session.answer(card_id: card.id, flag: "incorrect") }
        assert_equal Time.now + 60, session.next_card_at
      end
    end
  end

end

