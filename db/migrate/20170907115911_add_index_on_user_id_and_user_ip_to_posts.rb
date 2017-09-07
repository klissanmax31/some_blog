class AddIndexOnUserIdAndUserIpToPosts < ActiveRecord::Migration[5.1]
  def change
    add_index :posts, [:user_ip, :user_id]
  end
end
