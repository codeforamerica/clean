class AddPdfToCase < ActiveRecord::Migration
  def change
    add_attachment :cases, :pdf
  end
end
