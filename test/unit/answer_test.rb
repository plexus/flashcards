require_relative "../test_helper.rb"

describe Answer do

  let(:answer) { Answer.new }

  describe "::new" do
    it "should set interval to 1 by default" do
      assert_equal 1, answer.interval
    end

    it "should set at to the current time by default" do
      Timecop.freeze do
        assert_equal Time.now, answer.at
      end
    end

    it "should set easing to 2.0 by default" do
      assert_equal 2.0, answer.easing
    end

    it "should set interval if given" do
      assert_equal 12, Answer.new(12).interval
    end

    it "should set at if given" do
      Timecop.freeze do
        assert_equal Time.now - 3600, Answer.new(1, Time.now - 3600).at
      end
    end

    it "should set easing if given" do
      assert_equal 2.2, Answer.new(1, Time.now, 2.2).easing
    end
  end

  describe "#==" do
    it "should compare against interval" do
      Timecop.freeze do
        assert Answer.new == Answer.new
        assert Answer.new != Answer.new(10)
      end
    end

    it "should compare against at" do
      Timecop.freeze do
        assert Answer.new == Answer.new
        assert Answer.new != Answer.new(1, Time.now + 60)
      end
    end

    it "should compare against easing" do
      Timecop.freeze do
        assert Answer.new == Answer.new
        assert Answer.new != Answer.new(1, Time.now, 2.2)
      end
    end

    it "should compare wether the given object is an Answer" do
      Timecop.freeze do
        assert Answer.new == Answer.new
        assert Answer.new != stub(interval: 1, at: Time.now)
      end
    end
  end

  describe "#correct" do
    it "should set interval to 15 for the first correct answer" do
      answer.correct
      assert_equal 15, answer.interval
    end

    it "should increment easing by 0.2" do
      answer.correct
      assert_equal 2.2, answer.easing
    end

    it "should multiply interval with the easing factor for subsequent correct answers" do
      answer.correct # easing 2.2
      answer.correct # easing 2.4
      assert_equal (15 * 2.4).round(1), answer.interval
      answer.correct # easing 2.6
      assert_equal (15 * 2.4 * 2.6).round(1), answer.interval
    end

    it "should set at to the current time" do
      answer = Answer.new(1, Time.now - 3600)
      Timecop.freeze do
        answer.correct
        assert_equal Time.now, answer.at
      end
    end
  end

  describe "#incorrect" do
    it "should set interval to 1" do
      answer = Answer.new(10)
      answer.incorrect
      assert_equal 1, answer.interval
    end

    it "should decrement easing by 0.2" do
      answer.incorrect
      assert_equal 1.8, answer.easing
    end

    it "should never decrement easing below 1.0" do
      answer = Answer.new(1, Time.now, 1.0)
      answer.incorrect
      assert_equal 1.0, answer.easing
    end

    it "should set at to the current time" do
      answer = Answer.new(1, Time.now - 3600)
      Timecop.freeze do
        answer.incorrect
        assert_equal Time.now, answer.at
      end
    end
  end

  describe "#repeat_at" do
    it "should add interval in minutes to at" do
      Timecop.freeze do
        assert_equal Time.now + 60, answer.repeat_at
        answer = Answer.new(30)
        assert_equal Time.now + 30 * 60, answer.repeat_at
      end
    end
  end

end
