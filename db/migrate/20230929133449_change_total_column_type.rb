class ChangeTotalColumnType < ActiveRecord::Migration[7.0]
  def change
    change_column :epoches, :total_points, :string
    change_column :epoches, :total_mentions, :string
  end
end
