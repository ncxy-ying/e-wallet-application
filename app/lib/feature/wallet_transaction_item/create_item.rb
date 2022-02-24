class Feature::WalletTransactionItem::CreateItem
	def initialize(tx_id, user_id, tx_type, payload, notes=nil)
		@tx_id = tx_id
		@tx_type = tx_type
		@payload = payload
		@notes = notes
		@wallet_transaction = WalletTransaction.find_by(id: tx_id)
		@user = User.find_by(id: user_id)
	end

	def call
		raise "User Not Found" unless @user.present?
		raise "Wallet Transaction Not Found" unless @wallet_transaction.present?

		tx_tracking = WalletTransactionItem.create({
			wallet_transaction_id: @wallet_transaction.id,
			item_type: @tx_type,
			user_id: @user.id,
			transaction_on: Time.now,
			notes: @notes,
			payload: @payload
		})
	end
end
