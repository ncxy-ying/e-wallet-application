require 'rails_helper'
require 'faker'

RSpec.describe Feature::WalletTransactionItem::CreateItem do
    describe 'call' do
        def call_service(tx_id, user_id, tx_type, payload, notes=nil)
            Feature::WalletTransactionItem::CreateItem.new(
                tx_id,
                user_id,
                tx_type,
                payload,
                notes
            ).call
        end

        describe 'have existing user & wallet transaction' do
            user = User.create({ email: Faker::Internet.unique.email })
            positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)
            wallet_tx = Feature::WalletTransaction::CreateTx.new(user.id, positive_amount).call
            item_type = 'deposit'
            notes = 'Added deposit'
            payload = {
                'Deposit': positive_amount,
                'Total': user.wallet_balance.to_f
            }

            context 'with all params' do
                before do
                    call_service(wallet_tx.id, user.id, item_type, payload, notes)
                end

                it 'create a Wallet Transaction Item' do
                    expect(user.wallet_transaction_items.count).to eq(1)
                    item = WalletTransactionItem.take
                    expect(item.wallet_transaction_id).to eq(wallet_tx.id)
                    expect(item.item_type).to eq(item_type)
                    expect(item.user_id).to eq(user.id)
                    expect(item.notes).to eq(notes)
                    expect(item.payload["Deposit"]).to eq(payload[:Deposit])
                    expect(item.payload["Total"]).to eq(payload[:Total])
                end 
            end

            context 'without notes and payload' do
                before do
                    call_service(wallet_tx.id, user.id, item_type, nil)
                end

                it 'create a Wallet Transaction Item' do
                    expect(user.wallet_transaction_items.count).to eq(1)
                    item = WalletTransactionItem.take
                    expect(item.wallet_transaction_id).to eq(wallet_tx.id)
                    expect(item.item_type).to eq(item_type)
                    expect(item.user_id).to eq(user.id)
                    expect(item.notes).to eq(nil)
                    expect(item.payload).to eq(nil)
                    # expect(item.payload["Deposit"]).to eq(payload[:Deposit])
                    # expect(item.payload["Total"]).to eq(payload[:Total])
                end 
            end

            context 'without item_type' do
                it 'raise error' do
                    expect { call_service(wallet_tx.id, user.id, nil, payload) }.to \
                    raise_error(ActiveRecord::NotNullViolation)
                end
            end

            context 'without wallet_tx.id' do
                it 'raise error' do
                    expect { call_service(nil, user.id, item_type, payload) }.to \
                    raise_error(RuntimeError)
                end
            end
            context 'without user.id' do
                it 'raise error' do
                    expect { call_service(wallet_tx.id, nil, item_type, payload) }.to \
                    raise_error(RuntimeError)
                end
            end
        end
    end
end