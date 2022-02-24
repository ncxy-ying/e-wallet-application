require 'rails_helper'
require 'faker'

RSpec.describe Feature::WalletTransaction::Withdraw do
    describe 'call' do
        def call_service(user_id, amount)
            Feature::WalletTransaction::Withdraw.new(user_id, amount).call
        end

        describe 'have existing user' do
            user = User.create({ email: Faker::Internet.unique.email })

            context 'with positive amount with wallet balance' do

                positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)
                deposit_amount = Faker::Number.decimal(l_digits: 4, r_digits: 2)
                item_payload = {
                    'Withdraw': positive_amount,
                    'Total': (deposit_amount - positive_amount).round(2)
                }

                before do
                    # Add $$ to user
                    Feature::WalletTransaction::Deposit.new(user.id, deposit_amount).call
                    a = call_service(user.id, positive_amount)
                end

                it 'create a Wallet Transaction & withdraw Wallet Transaction Item' do
                    expect(user.wallet_balance).to eq((deposit_amount - positive_amount).to_d(8))
                    expect(user.wallet_transactions.count).to eq(2)
                    expect(WalletTransaction.last.amount).to eq(-positive_amount.to_d(8))
                    expect(user.wallet_transaction_items.withdraw.count).to eq(1)
                    item = user.wallet_transaction_items.withdraw.take
                    expect(item.payload["Withdraw"]).to eq(item_payload[:Withdraw])
                    expect(item.payload["Total"]).to eq(item_payload[:Total])
                end 
            end

            context 'with positive amount more than wallet balance' do

                positive_amount = Faker::Number.decimal(l_digits: 4, r_digits: 2)
                deposit_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)

                before do
                    # Deposit $$ to sender
                    Feature::WalletTransaction::Deposit.new(user.id, deposit_amount).call
                end

                it 'raise error' do
                    expect { call_service(user.id, positive_amount) }.to \
                    raise_error(RuntimeError)
                end
            end

            context 'with positive amount with 0 wallet balance' do
                positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)

                it 'raise error' do
                    expect { call_service(user.id, positive_amount) }.to \
                    raise_error(RuntimeError)
                end
            end

            context 'with negative amount' do
                negative_amount = Faker::Number.negative

                it 'raise error' do
                    expect { call_service(user.id, negative_amount) }.to \
                    raise_error(RuntimeError)
                end 
            end

            context 'with string type amount' do
                string_type_amount = Faker::Lorem.word

                it 'raise error' do
                    expect { call_service(user.id, string_type_amount) }.to \
                    raise_error(RuntimeError)
                end 
            end
        end

        describe 'no existing user' do
            context 'with positive amount' do
                positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)
                not_user_id = Faker::Number.number(digits: 5)

                it 'raise error' do
                    expect { call_service(not_user_id, positive_amount) }.to \
                    raise_error(RuntimeError)
                end 
            end

        end
    end
end