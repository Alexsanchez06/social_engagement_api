class AddEodColumnInReward < ActiveRecord::Migration[7.0]
  def change
    add_column :rewards, :eod, :jsonb
  end
end
