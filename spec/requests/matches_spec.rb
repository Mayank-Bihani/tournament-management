# spec/requests/matches_spec.rb
require "rails_helper"

RSpec.describe "Matches", type: :request do
  describe "GET /matches" do
    it "returns HTTP 200" do
      get matches_path
      expect(response).to have_http_status(:ok)
    end

    it "shows recorded match results" do
      alice = create(:player, name: "Alice")
      bob   = create(:player, name: "Bob")
      create(:match, winner: alice, loser: bob, played_on: Date.today)

      get matches_path
      expect(response.body).to include("Alice", "Bob")
    end
  end

  describe "GET /matches/new" do
    context "with at least 2 players" do
      it "returns HTTP 200" do
        create_list(:player, 2)
        get new_match_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "with fewer than 2 players" do
      it "redirects to players with an alert" do
        create(:player)
        get new_match_path
        expect(response).to redirect_to(players_path)
        follow_redirect!
        expect(response.body).to include("at least 2 players")
      end
    end
  end

  describe "POST /matches" do
    let!(:winner) { create(:player, name: "Winner") }
    let!(:loser)  { create(:player, name: "Loser") }

    context "with valid params" do
      it "creates a match and redirects" do
        expect {
          post matches_path, params: { match: { winner_id: winner.id, loser_id: loser.id, played_on: Date.today } }
        }.to change(Match, :count).by(1)

        expect(response).to redirect_to(matches_path)
        follow_redirect!
        expect(response.body).to include("Winner defeated Loser")
      end
    end

    context "when winner equals loser" do
      it "does not save and re-renders the form" do
        expect {
          post matches_path, params: { match: { winner_id: winner.id, loser_id: winner.id, played_on: Date.today } }
        }.not_to change(Match, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("cannot play against themselves")
      end
    end

    context "when winner_id is missing" do
      it "re-renders the form as unprocessable" do
        expect {
          post matches_path, params: { match: { winner_id: "", loser_id: loser.id, played_on: Date.today } }
        }.not_to change(Match, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /matches/:id" do
    it "removes the match and redirects" do
      match = create(:match)
      expect {
        delete match_path(match)
      }.to change(Match, :count).by(-1)

      expect(response).to redirect_to(matches_path)
      follow_redirect!
      expect(response.body).to include("Match result has been deleted")
    end

    it "redirects with alert when match not found" do
      delete match_path(id: 999_999)
      expect(response).to redirect_to(matches_path)
      follow_redirect!
      expect(response.body).to include("Match not found")
    end
  end
end
