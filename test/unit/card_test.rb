require_relative "../test_helper.rb"

describe Card do

  describe "#==" do
    it "should compare against id" do
      assert Card.new(0, "a", "A") == Card.new(0, "a", "A")
      assert Card.new(1, "a", "A") != Card.new(0, "a", "A")
    end

    it "should compare against front" do
      assert Card.new(0, "a", "A") == Card.new(0, "a", "A")
      assert Card.new(0, "b", "A") != Card.new(0, "a", "A")
    end

    it "should compare against back" do
      assert Card.new(0, "a", "A") == Card.new(0, "a", "A")
      assert Card.new(0, "a", "B") != Card.new(0, "a", "A")
    end

    it "should compare wether the given object is a Card" do
      assert Card.new(0, "a", "A") == Card.new(0, "a", "A")
      assert Card.new(0, "a", "A") != stub(id: 0, front: "a", back: "A")
    end
  end

end
