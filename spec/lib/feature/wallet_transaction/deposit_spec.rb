require 'rails_helper'
require 'faker'

RSpec.describe Feature::WalletTransaction::Deposit do
    describe 'call' do
        def call_service(user_id, amount)
            Feature::WalletTransaction::Deposit.new(user_id, amount).call
        end

        describe 'have existing user' do
            user = User.create({ email: Faker::Internet.unique.email })

            context 'with positive amount' do
                positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)
                item_payload = {
                    'Deposit': positive_amount,
                    'Total': positive_amount
                }

                it 'create a Wallet Transaction & Wallet Transaction Item' do
                    call_service(user.id, positive_amount)
                    expect(user.wallet_balance).to eq(positive_amount)
                    expect(user.wallet_transactions.count).to eq(1)
                    expect(user.wallet_transactions.take.amount).to eq(positive_amount.to_d(8))
                    expect(user.wallet_transaction_items.deposit.count).to eq(1)
                    item = user.wallet_transaction_items.deposit.take
                    expect(item.payload["Deposit"]).to eq(item_payload[:Deposit])
                    expect(item.payload["Total"]).to eq(item_payload[:Total])
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