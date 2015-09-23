require_relative "../test_helper.rb"

describe "app" do

  before do
    ENV.delete("DECK")
    reset_storage
  end

  after do
    ENV.delete("DECK")
    reset_storage
  end

  describe "GET /" do
    before do
      @session = Session.new(deck_id: "hiragana")
      Session.stubs(:new).returns(@session)
    end

    it "should create a new session with deck_id: hiragana by default" do
      @session.expects(:save)
      get "/"
    end

    it "should redirect to /sessions/:session_id" do
      get "/"
      assert_equal 302, last_response.status
      assert_equal "http://example.org/sessions/#{@session.id}", last_response.headers["Location"]
    end

    it "should create a new session with deck_id: from DECK environment variable if set" do
      ENV["DECK"] = "alphabet"
      session = stub(id: "foo", save: nil)
      Session.expects(:new).with(deck_id: "alphabet").returns(session)
      session.expects(:save)
      get "/"
    end
  end

  describe "GET /sessions/:session_id" do
    before do
      @session = Session.new(deck_id: "alphabet")
      @session.save
      @next_card = @session.pile.first
      @session.stubs(:next_card).returns(@next_card)
      Session.stubs(:load).returns(@session)
    end

    it "should show the sessions next card" do
      visit "/sessions/#{@session.id}"
      assert_selector(".front", text: @next_card.front)
      assert_selector(".back", text: @next_card.back)
    end
  end

  describe "POST /sessions/:session_id/cards/:card_id" do
    before do
      @session = Session.new(deck_id: "alphabet")
      @session.save
    end

    it "should mark the given card_id as answered" do
      Timecop.freeze do
        post "/sessions/#{@session.id}", card_id: 1, flag: "correct"
        session = Session.load(@session.id)
        answer = Answer.new
        answer.correct
        assert_equal [nil, answer], session.answers
      end
    end

    it "should do nothing on invalid input" do
      post "/sessions/#{@session.id}/cards/-1"
      session = Session.load(@session.id)
      assert_empty session.answers
    end
  end

  describe "POST /restart" do
    it "should redirect to /" do
      post "/restart"
      assert_equal 302, last_response.status
      assert_equal "http://example.org/", last_response.headers["Location"]
    end
  end

end

