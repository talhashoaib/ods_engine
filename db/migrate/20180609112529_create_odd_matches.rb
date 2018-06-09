class CreateOddMatches < ActiveRecord::Migration
  def change
    create_table :odd_matches do |t|
      t.string :odd_id
      t.string :country
      t.string :league
      t.string :home_team
      t.string :away_team
      t.boolean :in_play
      t.string :time
      t.string :score
      t.string :homewin
      t.string :draw
      t.string :awaywin
      t.string :bs
      t.string :url

      t.timestamps null: false
    end
    add_index :odd_matches, :odd_id
  end
end
