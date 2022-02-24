require 'rails_helper'
require 'faker'

RSpec.describe Feature::WalletTransaction::CreateTx do
    describe 'call' do
        def call_service(user_id, amount)
            Feature::WalletTransaction::CreateTx.new(user_id, amount).call
        end

        describe 'have existing user' do
            user = User.create({ email: Faker::Internet.unique.email })

            context 'with positive amount' do
                positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)
                before do
                    call_service(user.id, positive_amount)
                end
                it 'create a Wallet Transaction' do
                    expect(user.wallet_balance).to eq(positive_amount)
                    expect(user.wallet_transactions.count).to eq(1)
                end 
            end

            context 'with negative amount' do
                negative_amount = -Faker::Number.decimal(l_digits: 3, r_digits: 2)
                before do
                    call_service(user.id, negative_amount)
                end

                it 'create a Wallet Transaction' do
                    expect(user.wallet_balance).to eq(negative_amount)
                    expect(user.wallet_transactions.count).to eq(1)
                end 
            end

            context 'with string type amount' do
                string_type_amount = Faker::Lorem.word

                it 'raise error' do
                    expect { call_service(user.id, string_type_amount) }.to \
                    raise_error(RuntimeError)
                end 
            end

            context 'call without amount' do
                it 'raise error' do
                    expect { call_service(user.id, nil) }.to \
                    raise_error(RuntimeError)
                end 
            end

            context 'call without user_id' do
                positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)
                it 'raise error' do
                    expect { call_service(nil, positive_amount) }.to \
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