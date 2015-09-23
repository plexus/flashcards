require "securerandom"
require "yaml/store"

class Session

  class NotFound < StandardError; end

  def self.directory
    Root.join("data", ENV["RACK_ENV"], "sessions")
  end

  def self.load(id)
    path = directory.join("#{id}.yml")
    raise NotFound unless path.file?
    db = YAML::Store.new(path)
    db.transaction do
      values = db.roots.map { |key| db[key] }
      data = Hash[db.roots.zip(values)]
      new(**data)
    end
  end

  attr_reader :id, :deck_id

  def initialize(id: SecureRandom.uuid, deck_id: nil, answers: [])
    @id, @deck_id, @answers = id, deck_id, answers
  end

  def save
    directory.mkpath unless directory.directory?
    db = YAML::Store.new(self.class.directory.join("#{id}.yml"))
    db.transaction do
      db[:id], db[:deck_id], db[:answers] = id, deck_id, answers
    end
  end

  def deck
    @deck ||= Deck.read_from_csv(deck_id)
  end

  def answers
    @answers.map(&:freeze).freeze
  end

  def pile
    zipped = deck.cards.zip(@answers)
    zipped.sort! do |(_, a), (_, b)|
      a = a.nil? ? a.to_i : a.repeat_at.to_i
      b = b.nil? ? b.to_i : b.repeat_at.to_i
      a <=> b
    end
    zipped.map(&:first)
  end

  def next_card
    card = pile.first
    return card unless answer = answers[card.id]
    return card if Time.now >= answer.repeat_at
    nil
  end

  def next_card_at
    return Time.now unless answer = answers[pile.first.id]
    answer.repeat_at
  end

  def answer(card_id:, flag:)
    return if card_id.nil?
    return unless card_id.to_s =~ /\A\d+\Z/
    return unless deck.cards[card_id.to_i]
    return unless %w[correct incorrect].include?(flag)
    card_id = card_id.to_i
    @answers[card_id] ||= Answer.new
    @answers[card_id].send(flag)
  end

  def directory; self.class.directory end
end

