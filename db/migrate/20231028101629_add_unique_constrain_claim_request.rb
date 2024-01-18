class AddUniqueConstrainClaimRequest < ActiveRecord::Migration[7.0]
  def change
    add_index :claim_requests, [:user_id, :epoch_id], unique: true
  end
end
