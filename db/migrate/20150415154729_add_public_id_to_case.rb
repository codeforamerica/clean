class AddPublicIdToCase < ActiveRecord::Migration
  def change
    add_column :cases, :public_id, :string
  end
end
