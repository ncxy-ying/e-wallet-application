require 'rails_helper'
require 'faker'

RSpec.describe Feature::WalletTransaction::Transfer do
    describe 'call' do
        def call_service(sender_id, recipient_id, amount, notes=nil)
            Feature::WalletTransaction::Transfer.new(sender_id, recipient_id, amount, notes).call
        end

        describe 'have existing user' do
            sender = User.create({ email: Faker::Internet.unique.email })
            recipient = User.create({ email: Faker::Internet.unique.email })

            context 'with positive amount with wallet balance' do
                positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)
                deposit_amount = Faker::Number.decimal(l_digits: 4, r_digits: 2)
                sender_wallet_balance = (deposit_amount - positive_amount).to_d(8)
                notes = "For Activity 1"
                sender_item_payload = {
                    'Transfer': positive_amount,
                    'Recipient': recipient.id,
                    'Total': (deposit_amount - positive_amount).round(2)
                }

                recipient_item_payload = {
                    'Receive': positive_amount,
                    'Sender': sender.id,
                    'Total': positive_amount
                }

                before do
                    # Add $$ to sender
                    Feature::WalletTransaction::Deposit.new(sender.id, deposit_amount).call
                    call_service(sender.id, recipient.id, positive_amount, notes)
                end

                it do
                    # Sender
                    expect(sender.wallet_balance).to eq(sender_wallet_balance)
                    expect(sender.wallet_transactions.count).to eq(2)
                    expect(sender.wallet_transactions.last.amount).to eq(-positive_amount.to_d(8))
                    expect(sender.wallet_transaction_items.deposit.count).to eq(1)
                    expect(sender.wallet_transaction_items.transfer.count).to eq(1)

                    sender_item = sender.wallet_transaction_items.transfer.take
                    expect(sender_item.notes).to eq(notes)
                    expect(sender_item.payload["Transfer"]).to eq(sender_item_payload[:Transfer])
                    expect(sender_item.payload["Recipient"]).to eq(sender_item_payload[:Recipient])
                    expect(sender_item.payload["Total"]).to eq(sender_item_payload[:Total])

                    # Recipient
                    expect(recipient.wallet_balance).to eq(positive_amount)
                    expect(recipient.wallet_transactions.count).to eq(1)
                    expect(recipient.wallet_transactions.take.amount).to eq(positive_amount.to_d(8))
                    recipient_receive_items = recipient.wallet_transaction_items.receive
                    expect(recipient_receive_items.count).to eq(1)

                    recipient_receive_item = recipient_receive_items.take
                    expect(recipient_receive_item.notes).to eq(notes)
                    expect(recipient_receive_item.payload["Receive"]).to eq(recipient_item_payload[:Receive])
                    expect(recipient_receive_item.payload["Sender"]).to eq(recipient_item_payload[:Sender])
                    expect(recipient_receive_item.payload["Total"]).to eq(recipient_item_payload[:Total])
                end 
            end

            context 'with positive amount more than wallet balance' do

                positive_amount = Faker::Number.decimal(l_digits: 4, r_digits: 2)
                deposit_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)

                before do
                    # Deposit $$ to sender
                    Feature::WalletTransaction::Deposit.new(sender.id, deposit_amount).call
                end

                it 'raise error' do
                    expect { call_service(sender.id, recipient.id, positive_amount) }.to \
                    raise_error(RuntimeError)
                end
            end

            context 'with positive amount with 0 wallet balance' do
                positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)

                it 'raise error' do
                    expect { call_service(sender.id, recipient.id, positive_amount) }.to \
                    raise_error(RuntimeError)
                end
            end

            context 'with negative amount' do
                negative_amount = Faker::Number.negative

                it 'raise error' do
                    expect { call_service(sender.id, recipient.id, negative_amount) }.to \
                    raise_error(RuntimeError)
                end 
            end

            context 'with string type amount' do
                string_type_amount = Faker::Lorem.word

                it 'raise error' do
                    expect { call_service(sender.id, recipient.id, string_type_amount) }.to \
                    raise_error(RuntimeError)
                end 
            end
        end

        describe 'no existing user' do
            sender = User.create({ email: Faker::Internet.unique.email })
            recipient = User.create({ email: Faker::Internet.unique.email })

            context 'sender' do
                positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)
                not_user_id = Faker::Number.number(digits: 5)

                it 'raise error' do
                    expect { call_service(sender.id, not_user_id, positive_amount) }.to \
                    raise_error(RuntimeError)
                end 
            end

            context 'recipient' do
                positive_amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)
                not_user_id = Faker::Number.number(digits: 5)

                it 'raise error' do
                    expect { call_service(not_user_id, recipient.id, positive_amount) }.to \
                    raise_error(RuntimeError)
                end 
            end

        end
    end
end