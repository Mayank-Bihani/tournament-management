class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.references :winner, null: false, foreign_key: { to_table: :players }
      t.references :loser,  null: false, foreign_key: { to_table: :players }
      t.date :played_on, null: false, default: -> { "CURRENT_DATE" }
      t.timestamps
    end

    add_check_constraint :matches, "winner_id != loser_id", name: "matches_players_differ"
  end
end
