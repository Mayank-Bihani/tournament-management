# spec/models/player_spec.rb
require "rails_helper"

RSpec.describe Player, type: :model do
  # ── Associations ──────────────────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to have_many(:won_matches).class_name("Match").with_foreign_key(:winner_id).dependent(:destroy) }
    it { is_expected.to have_many(:lost_matches).class_name("Match").with_foreign_key(:loser_id).dependent(:destroy) }
  end

  # ── Validations ───────────────────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    # shoulda-matchers needs an existing record with a valid name to test uniqueness
    it "validates uniqueness of name case-insensitively" do
      create(:player, name: "Alice")
      duplicate = build(:player, name: "alice")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it { is_expected.to validate_length_of(:name).is_at_most(100) }
  end

  # ── Instance methods ──────────────────────────────────────────────────────
  describe "#wins" do
    it "returns the number of matches the player has won" do
      player = create(:player)
      create_list(:match, 3, winner: player)
      expect(player.wins).to eq(3)
    end
  end

  describe "#losses" do
    it "returns the number of matches the player has lost" do
      player = create(:player)
      create_list(:match, 2, loser: player)
      expect(player.losses).to eq(2)
    end
  end

  describe "#total_matches" do
    it "sums wins and losses" do
      player = create(:player)
      create(:match, winner: player)
      create(:match, loser: player)
      expect(player.total_matches).to eq(2)
    end
  end

  describe "#win_rate" do
    it "returns 0.0 when the player has no matches" do
      player = create(:player)
      expect(player.win_rate).to eq(0.0)
    end

    it "calculates the correct percentage" do
      player = create(:player)
      create_list(:match, 3, winner: player)
      create_list(:match, 1, loser: player)
      expect(player.win_rate).to eq(75.0)
    end
  end

  describe "#matches" do
    it "returns all matches the player participated in" do
      player  = create(:player)
      other   = create(:player)
      third   = create(:player)
      m1 = create(:match, winner: player, loser: other)
      m2 = create(:match, winner: third,  loser: player)
      _unrelated = create(:match, winner: other, loser: third)

      expect(player.matches).to contain_exactly(m1, m2)
    end
  end

  # ── Scopes ────────────────────────────────────────────────────────────────
  describe ".ranked" do
    it "orders players by wins descending" do
      low  = create(:player)
      high = create(:player)
      create_list(:match, 1, winner: low,  loser: high)
      create_list(:match, 3, winner: high, loser: low)

      ranked = Player.ranked
      expect(ranked.first.id).to eq(high.id)
    end

    it "uses losses ascending as a tiebreaker" do
      fewer_losses = create(:player)
      more_losses  = create(:player)
      third        = create(:player)

      create_list(:match, 2, winner: fewer_losses, loser: third)
      create_list(:match, 2, winner: more_losses,  loser: third)
      create(:match, winner: third, loser: more_losses)

      ranked = Player.ranked
      expect(ranked.first.id).to eq(fewer_losses.id)
    end

    it "exposes wins_count and losses_count attributes" do
      player = create(:player)
      create_list(:match, 2, winner: player)
      create_list(:match, 1, loser: player)

      ranked_player = Player.ranked.find { |p| p.id == player.id }
      expect(ranked_player.wins_count).to eq(2)
      expect(ranked_player.losses_count).to eq(1)
    end

    it "includes players with no matches" do
      player = create(:player)
      expect(Player.ranked.map(&:id)).to include(player.id)
    end
  end
end