class CreateEngineStates < ActiveRecord::Migration
  def change
    create_table :engine_states do |t|
      t.string :name
      t.boolean :started

      t.timestamps null: false
    end
  end
end
