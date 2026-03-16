class PlayersController < ApplicationController
  before_action :set_player, only: %i[show destroy]

  # GET /players
  def index
    @players = Player.ranked
  end

  # GET /players/:id
  def show
    @recent_matches = @player.matches.includes(:winner, :loser).recent.limit(10)
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # POST /players
  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to players_path, notice: "#{@player.name} has been added to the league."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /players/:id
  def destroy
    name = @player.name
    @player.destroy
    redirect_to players_path, notice: "#{name} has been removed from the league."
  end

  private

  def set_player
    @player = Player.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to players_path, alert: "Player not found."
  end

  def player_params
    params.require(:player).permit(:name)
  end
end
