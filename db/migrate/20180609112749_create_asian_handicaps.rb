class CreateAsianHandicaps < ActiveRecord::Migration
  def change
    create_table :asian_handicaps do |t|
      t.string :name
      t.string :home_team
      t.string :away_team
      t.string :payout
      t.integer :odd_match_id

      t.timestamps null: false
    end
    add_index :asian_handicaps, :odd_match_id
  end
end
