class WalletTransaction < ApplicationRecord
  belongs_to :user
  has_many :wallet_transaction_items
end
