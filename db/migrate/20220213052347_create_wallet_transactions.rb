class CreateWalletTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :wallet_transactions do |t|
      t.decimal :amount, :precision => 8, :scale => 2, null: false
      t.datetime :transaction_on, null: false
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
