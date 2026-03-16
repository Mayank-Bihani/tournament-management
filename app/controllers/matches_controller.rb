class MatchesController < ApplicationController
  before_action :set_match, only: [:destroy]
  before_action :require_enough_players, only: %i[new create]

  # GET /matches
  def index
    @matches = Match.includes(:winner, :loser).recent
  end

  # GET /matches/new
  def new
    @match   = Match.new(played_on: Date.today)
    @players = Player.order(:name)
  end

  # POST /matches
  def create
    @match = Match.new(match_params)

    if @match.save
      redirect_to matches_path, notice: "Match recorded: #{@match.winner.name} defeated #{@match.loser.name}."
    else
      @players = Player.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /matches/:id
  def destroy
    @match.destroy
    redirect_to matches_path, notice: "Match result has been deleted."
  end

  private

  def set_match
    @match = Match.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to matches_path, alert: "Match not found."
  end

  def match_params
    params.require(:match).permit(:winner_id, :loser_id, :played_on)
  end

  def require_enough_players
    unless Player.count >= 2
      redirect_to players_path, alert: "You need at least 2 players before recording a match."
    end
  end
end
