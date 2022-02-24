class Feature::WalletTransaction::CreateTx
	def initialize(user_id, amount)
		@user = User.find_by(id: user_id)
		@amount = amount
	end

	def call
		raise "User Not Found" unless @user.present?

		# check amount is number
		raise "Amount is not a number" unless @amount.is_a? Numeric

		WalletTransaction.create({
			user_id: @user.id,
			amount: @amount,
			transaction_on: Time.now
		})
	end
end
