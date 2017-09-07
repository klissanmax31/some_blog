class AddAverageRateToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :average_rate, :float
    add_index :posts, :average_rate
  end
end
