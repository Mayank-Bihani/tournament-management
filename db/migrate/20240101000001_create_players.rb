class CreatePlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :players, :name, unique: true
  end
end
