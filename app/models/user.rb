class User < ApplicationRecord
	has_many :wallet_transactions
	has_many :wallet_transaction_items

	validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

	def wallet_balance
		self.wallet_transactions.sum(:amount)
	end
end
