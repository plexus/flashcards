class Answer

  attr_reader :interval, :at

  def initialize(interval = 1, at = Time.now)
    @interval, @at = interval, at
  end

  def correct
    @interval = interval == 1 ? 15 : interval * 2
    @at = Time.now
  end

  def incorrect
    @interval = 1
    @at = Time.now
  end

  def repeat_at
    at + interval * 60
  end

  def ==(other)
    other.is_a?(Answer) &&
      other.interval == interval &&
      other.at == at
  end

end
