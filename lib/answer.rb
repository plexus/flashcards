class Answer

  attr_reader :count, :at

  def initialize(count = 0, at = Time.now)
    @count, @at = count, at
  end

  def correct
    @count += 1
    @at = Time.now
  end

  def incorrect
    @count = 0
    @at = Time.now
  end

  def repeat_at
    space = count.zero? ? 60 : 15 * 60 * count
    at + space
  end

  def ==(other)
    other.is_a?(Answer) &&
      other.count == count &&
      other.at == at
  end

end
