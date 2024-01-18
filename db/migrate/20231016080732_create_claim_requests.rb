class CreateClaimRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :claim_requests do |t|
      t.references :reward, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.references :epoch, null: false, foreign_key: true, index: true
      t.string :quantity, null: false, default: 0      
      t.string :sign, null: false
      t.string :address, null: false
      t.string :allocated_tokens, null: false, default: 0      
      t.string :reference
      t.string :status, null: false      
      t.string :message
      t.datetime :claimed_at

      t.timestamps
    end
  end
end
