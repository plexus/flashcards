require_relative "../test_helper.rb"

describe Answer do

  let(:answer) { Answer.new }

  describe "::new" do
    it "should set count to 0 by default" do
      assert_equal 0, answer.count
    end

    it "should set at to the current time by default" do
      Timecop.freeze do
        assert_equal Time.now, answer.at
      end
    end

    it "should set count if given" do
      assert_equal 12, Answer.new(12).count
    end

    it "should set at if given" do
      Timecop.freeze do
        assert_equal Time.now - 3600, Answer.new(0, Time.now - 3600).at
      end
    end
  end

  describe "#==" do
    it "should compare against count" do
      Timecop.freeze do
        assert Answer.new == Answer.new
        assert Answer.new != Answer.new(10)
      end
    end

    it "should compare against at" do
      Timecop.freeze do
        assert Answer.new == Answer.new
        assert Answer.new != Answer.new(0, Time.now + 60)
      end
    end

    it "should compare wether the given object is an Answer" do
      Timecop.freeze do
        assert Answer.new == Answer.new
        assert Answer.new != stub(count: 0, at: Time.now)
      end
    end
  end

  describe "#correct" do
    it "should increase count by 1" do
      answer.correct
      assert_equal 1, answer.count
    end

    it "should set at to the current time" do
      answer = Answer.new(0, Time.now - 3600)
      Timecop.freeze do
        answer.correct
        assert_equal Time.now, answer.at
      end
    end
  end

  describe "#incorrect" do
    it "should set count 0" do
      answer = Answer.new(10)
      answer.incorrect
      assert_equal 0, answer.count
    end

    it "should set at to the current time" do
      answer = Answer.new(0, Time.now - 3600)
      Timecop.freeze do
        answer.incorrect
        assert_equal Time.now, answer.at
      end
    end
  end

  describe "#repeat_at" do
    it "should be one minute in the future if count zero (i.e. answer was incorrect)" do
      Timecop.freeze do
        assert_equal Time.now + 60, answer.repeat_at
      end
    end

    it "should space 15 minutes multiplied with each correct answer" do
      Timecop.freeze do
        answer.correct
        assert_equal Time.now + 15 * 60, answer.repeat_at
        answer.correct
        assert_equal Time.now + 2 * 15 * 60, answer.repeat_at
      end
    end
  end

end
