class WalletTransactionItem < ApplicationRecord
  belongs_to :wallet_transaction
  belongs_to :user

  enum item_type: [:deposit, :withdraw, :transfer, :receive] 
end
