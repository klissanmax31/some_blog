class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :login

      t.timestamps
    end
    add_index :users, :login
  end
end
