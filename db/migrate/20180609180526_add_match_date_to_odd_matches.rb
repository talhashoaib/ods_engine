class AddMatchDateToOddMatches < ActiveRecord::Migration
  def change
    add_column :odd_matches, :match_day, :datetime
  end
end
