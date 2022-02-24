class Feature::WalletTransaction::Withdraw
	def initialize(user_id, amount)
		@user = User.find_by(id: user_id)
		@amount = amount
	end

	def call
		raise "User Not Found" unless @user.present?

		# check amount is positive value and numeric
		raise "Amount is not a number" unless @amount.is_a? Numeric
		raise "Amount is less than 1" unless @amount.positive?

		# check user wallet balance
		raise "Amount is more than wallet balance" if amount_more_than_wallet_balance?

		# create Wallet Transaction
		tx = Feature::WalletTransaction::CreateTx.new(@user.id, -@amount).call

		if tx.persisted?
			payload = {
						'Withdraw': @amount,
						'Total': @user.wallet_balance.to_f
					}
			# create Wallet Transaction Item
			Feature::WalletTransactionItem::CreateItem.new(
				tx.id,
				@user.id,
				'withdraw',
				payload
			).call
		else
			raise "Unable to save transaction"
		end

		tx
	end

	private

	def amount_more_than_wallet_balance?
		@amount > @user.wallet_balance
	end
end
