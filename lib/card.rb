class Card

  attr_reader :id, :front, :back

  def initialize(id, front, back)
    @id, @front, @back = id, front, back
  end

  def ==(other)
    other.is_a?(Card) &&
      other.id == id &&
      other.front == front &&
      other.back == back
  end

end
