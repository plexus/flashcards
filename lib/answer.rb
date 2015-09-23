class Answer

  attr_reader :interval, :at, :easing

  def initialize(interval = 1, at = Time.now, easing = 2.0)
    @interval, @at, @easing = interval, at, easing
  end

  def correct
    @easing += 0.2
    @interval = interval == 1 ? 15 : (interval * @easing).round(1)
    @at = Time.now
  end

  def incorrect
    @easing = [easing - 0.2, 1.0].max
    @interval = 1
    @at = Time.now
  end

  def repeat_at
    at + interval * 60
  end

  def ==(other)
    other.is_a?(Answer) &&
      other.interval == interval &&
      other.at == at &&
      other.easing == easing
  end

end
