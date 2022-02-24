class CreateWalletTransactionItems < ActiveRecord::Migration[7.0]
  def change
    create_table :wallet_transaction_items do |t|
      t.belongs_to :wallet_transaction, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :item_type, null: false
      t.datetime :transaction_on, null: false
      t.text :notes
      t.json :payload

      t.timestamps
    end
  end
end
