require "securerandom"
require "yaml/store"

class Session

  class NotFound < StandardError; end

  def self.directory
    Root.join("data", ENV["RACK_ENV"], "sessions")
  end

  def self.load(id)
    path = directory.join("#{id}.yml")
    raise NotFound unless File.exist?(path)
    db = YAML::Store.new(path)
    db.transaction do
      values = db.roots.map { |key| db[key] }
      data = Hash[db.roots.zip(values)]
      new(**data)
    end
  end

  attr_reader :id, :deck_id, :answers

  def initialize(id: SecureRandom.uuid, deck_id:, answers: [])
    @id, @deck_id, @answers = id, deck_id, answers
  end

  def save
    FileUtils.mkdir_p(self.class.directory) unless File.directory?(self.class.directory)
    db = YAML::Store.new(self.class.directory.join("#{id}.yml"))
    db.transaction do
      db[:id], db[:deck_id], db[:answers] = id, deck_id, answers
    end
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

