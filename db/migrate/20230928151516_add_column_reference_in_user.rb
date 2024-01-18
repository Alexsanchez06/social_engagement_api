class AddColumnReferenceInUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :auth_reference, :string
  end
end
