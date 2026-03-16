# spec/models/match_spec.rb
require "rails_helper"

RSpec.describe Match, type: :model do
  # ── Associations ──────────────────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:winner).class_name("Player") }
    it { is_expected.to belong_to(:loser).class_name("Player") }
  end

  # ── Validations ───────────────────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:winner_id) }
    it { is_expected.to validate_presence_of(:loser_id) }
    it { is_expected.to validate_presence_of(:played_on) }

    context "when winner and loser are the same player" do
      it "is invalid" do
        player = create(:player)
        match  = build(:match, winner: player, loser: player)
        expect(match).not_to be_valid
        expect(match.errors[:base]).to include("A player cannot play against themselves")
      end
    end

    context "when winner and loser are different players" do
      it "is valid" do
        match = build(:match)
        expect(match).to be_valid
      end
    end
  end

  # ── Callbacks ─────────────────────────────────────────────────────────────
  describe "before_validation: set_played_on" do
    it "defaults played_on to today when not provided" do
      match = build(:match, played_on: nil)
      match.valid?
      expect(match.played_on).to eq(Date.today)
    end

    it "does not overwrite an explicitly provided date" do
      date  = Date.new(2024, 6, 15)
      match = build(:match, played_on: date)
      match.valid?
      expect(match.played_on).to eq(date)
    end
  end

  # ── Scopes ────────────────────────────────────────────────────────────────
  describe ".recent" do
    it "returns matches ordered by played_on descending" do
      older  = create(:match, played_on: 3.days.ago)
      newer  = create(:match, played_on: 1.day.ago)
      expect(Match.recent.to_a).to eq([newer, older])
    end
  end

  # ── Dependent destroy ─────────────────────────────────────────────────────
  describe "dependent: :destroy on player deletion" do
    it "removes associated matches when a player is deleted" do
      player = create(:player)
      create(:match, winner: player)
      expect { player.destroy }.to change(Match, :count).by(-1)
    end
  end
end
