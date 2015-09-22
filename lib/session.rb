class Session

  attr_reader :deck_id, :answers

  def initialize(deck_id:, answers: [])
    @deck_id, @answers = deck_id, answers
  end

  def deck
    @deck ||= Deck.read_from_csv(deck_id)
  end

  def pile
    deck.cards.zip(answers).reject { |_, answered| answered }.map(&:first)
  end

  def next_card
    pile.sample
  end

  def answer(card_id)
    return if card_id.nil?
    return unless card_id.to_s =~ /\A\d+\Z/
    return unless deck.cards[card_id.to_i]
    @answers[card_id.to_i] = true
  end

end

