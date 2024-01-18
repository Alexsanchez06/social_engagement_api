class CreateEpoches < ActiveRecord::Migration[7.0]
  def change
    create_table :epoches do |t|
      t.string :name, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.boolean :alive, default: false, null: false, index: true
      t.integer :total_points, default: 0, null: false
      t.integer :total_mentions, default: 0, null: false
      t.integer :total_participants, default: 0, null: false
      t.integer :last_calculated_activity_id

      t.timestamps
    end
  end
end
