# spec/requests/players_spec.rb
require "rails_helper"

RSpec.describe "Players", type: :request do
  describe "GET /players" do
    it "returns HTTP 200" do
      get players_path
      expect(response).to have_http_status(:ok)
    end

    it "lists players ordered by rank" do
      alice = create(:player, name: "Alice")
      bob   = create(:player, name: "Bob")
      create_list(:match, 3, winner: alice, loser: bob)

      get players_path
      expect(response.body).to include("Alice", "Bob")
    end
  end

  describe "GET /players/:id" do
    it "returns HTTP 200 for an existing player" do
      player = create(:player)
      get player_path(player)
      expect(response).to have_http_status(:ok)
    end

    it "redirects with alert for a missing player" do
      get player_path(id: 999_999)
      expect(response).to redirect_to(players_path)
      follow_redirect!
      expect(response.body).to include("Player not found")
    end
  end

  describe "GET /players/new" do
    it "returns HTTP 200" do
      get new_player_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /players" do
    context "with valid params" do
      it "creates a player and redirects" do
        expect {
          post players_path, params: { player: { name: "Charlie" } }
        }.to change(Player, :count).by(1)

        expect(response).to redirect_to(players_path)
        follow_redirect!
        expect(response.body).to include("Charlie has been added")
      end
    end

    context "with a blank name" do
      it "does not create a player and re-renders the form" do
        expect {
          post players_path, params: { player: { name: "" } }
        }.not_to change(Player, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with a duplicate name" do
      it "re-renders the form with an error" do
        create(:player, name: "Dana")
        expect {
          post players_path, params: { player: { name: "Dana" } }
        }.not_to change(Player, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Name has already been taken")
      end
    end
  end

  describe "DELETE /players/:id" do
    it "removes the player and redirects" do
      player = create(:player)
      expect {
        delete player_path(player)
      }.to change(Player, :count).by(-1)

      expect(response).to redirect_to(players_path)
      follow_redirect!
      expect(response.body).to include("has been removed")
    end

    it "also removes the player's matches (cascade)" do
      player = create(:player)
      create(:match, winner: player)
      expect {
        delete player_path(player)
      }.to change(Match, :count).by(-1)
    end
  end
end
