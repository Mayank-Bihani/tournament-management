class Player < ApplicationRecord
  has_many :won_matches,  class_name: "Match", foreign_key: :winner_id, dependent: :destroy
  has_many :lost_matches, class_name: "Match", foreign_key: :loser_id,  dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }

  # Returns all matches this player participated in (won or lost)
  def matches
    Match.where("winner_id = ? OR loser_id = ?", id, id)
  end

  def wins
    won_matches.count
  end

  def losses
    lost_matches.count
  end

  def total_matches
    wins + losses
  end

  def win_rate
    return 0.0 if total_matches.zero?

    (wins.to_f / total_matches * 100).round(1)
  end

  def self.ranked
    wins_subquery = Match.select("winner_id, COUNT(*) AS wins_count")
                         .group("winner_id")
                         .to_sql

    losses_subquery = Match.select("loser_id, COUNT(*) AS losses_count")
                           .group("loser_id")
                           .to_sql

    joins(
      "LEFT JOIN (#{wins_subquery})   w ON w.winner_id = players.id",
      "LEFT JOIN (#{losses_subquery}) l ON l.loser_id  = players.id"
    )
      .select("players.*, COALESCE(w.wins_count, 0) AS wins_count, COALESCE(l.losses_count, 0) AS losses_count")
      .order("wins_count DESC, losses_count ASC, players.name ASC")
  end
end