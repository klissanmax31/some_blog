class CreateRates < ActiveRecord::Migration[5.1]
  def change
    create_table :rates do |t|
      t.references :post, foreign_key: true
      t.integer :value

      t.timestamps
    end
  end
end
