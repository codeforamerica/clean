class AddSignatureToCase < ActiveRecord::Migration
  def change
    add_column :cases, :signature, :string
    add_column :cases, :signature_agree, :boolean
  end
end
