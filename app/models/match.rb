class Match < ApplicationRecord
  belongs_to :winner, class_name: "Player"
  belongs_to :loser,  class_name: "Player"

  validates :winner_id, presence: true
  validates :loser_id,  presence: true
  validates :played_on, presence: true
  validate  :players_must_differ

  before_validation :set_played_on

  scope :recent, -> { order(played_on: :desc, created_at: :desc) }

  private

  def players_must_differ
    return unless winner_id.present? && loser_id.present?

    errors.add(:base, "A player cannot play against themselves") if winner_id == loser_id
  end

  def set_played_on
    self.played_on ||= Date.today
  end
end
