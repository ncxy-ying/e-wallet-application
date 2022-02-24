class Feature::WalletTransaction::Transfer
	def initialize(sender_id, recipient_id, amount, notes=nil)
		@sender = User.find_by(id: sender_id)
		@recipient = User.find_by(id: recipient_id)
		@amount = amount
		@notes = notes
	end

	def call
		raise "Sender Not Found" unless @sender.present?
		raise "Recipient Not Found" unless @recipient.present?

		# check amount is positive value and numeric
		raise "Amount is not a number" unless @amount.is_a? Numeric
		raise "Amount is less than 1" unless @amount.positive?

		# check user wallet balance
		raise "Amount is more than wallet balance" if amount_more_than_sender_wallet_balance?

		# create Wallet Transaction for sender & recipient
		sender_tx = Feature::WalletTransaction::CreateTx.new(@sender.id, -@amount).call
		recipient_tx = Feature::WalletTransaction::CreateTx.new(@recipient.id, @amount).call

		if sender_tx.persisted? && recipient_tx.persisted?
			sender_tx_payload = {
									'Transfer': @amount,
									'Recipient': @recipient.id,
									'Total': @sender.wallet_balance.to_f
								}
			recipient_tx_payload = {
									'Receive': @amount,
									'Sender': @sender.id,
									'Total': @recipient.wallet_balance.to_f,
								}

			# create sender Wallet Transaction Item
			Feature::WalletTransactionItem::CreateItem.new(
				sender_tx.id,
				@sender.id,
				'transfer',
				sender_tx_payload,
				@notes
			).call

			# create recipient Wallet Transaction Item
			Feature::WalletTransactionItem::CreateItem.new(
				recipient_tx.id,
				@recipient.id,
				'receive',
				recipient_tx_payload,
				@notes
			).call

		else
			raise "Unable to transfer"
		end
	end

	private

	def amount_more_than_sender_wallet_balance?
		@amount > @sender.wallet_balance
	end
end
