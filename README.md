# e-Wallet App

This is a demo e-wallet application written using Ruby on Rails with postgresql. The features of this application are deposit and withraw money from user, transfer money in between users. It also enabled user to track their transaction histories and check e-wallet balance. 

## Highlight

The features are written in a reusable manner. There are 3 models in this application, which is `User`, `Wallet Transaction`, and `Wallet Transaction Item`. `Wallet Transaction` is to record transaction amount and `Wallet Transaction Item` is to track transaction history for users. For example, deposit, withdrawal and transfer features will create a Wallet Transaction followed by transaction history by using `Feature::WalletTransaction::CreateTx.new(params).call` and `Feature::WalletTransactionItem::CreateItem.new(params).call`.

## Setup

```
# create database
$ rake db:create

# run migration
$ rake db:migrate

# install gem
$ bundle install

# run test
bundle exec rspec

# start server
$ rails s
```

## Try it out

Try out the features by using `rails console`

```

# start rails console
$ rails c

# create users
$ user_1 = User.create({email: Faker::Internet.unique.email})
$ user_2 = User.create({email: Faker::Internet.unique.email})

# deposit 1000 to user_1
$ Feature::WalletTransaction::Deposit.new(user_1.id, 1000).call

# Withdraw 500 to user_1
$ Feature::WalletTransaction::Withdraw.new(user_1.id, 500).call

# Transfer 50 from user_1 to user_2
$ Feature::WalletTransaction::Transfer.new(user_1.id,user_2.id, 50).call

# Transaction History can query by
$ user_1.wallet_transaction_items.all
$ user_2.wallet_transaction_items.all

```

## Find related files at

### Service Files

Wallet Transaction Services:

`app/lib/feature/wallet_transaction/`
* `create_tx.rb`
* `deposit.rb`
* `transfer.rb`
* `withdraw.rb`

Create Wallet Transaction Item Service:

`app/lib/feature/wallet_transaction_item/create_item.rb`

### Service Test Files

Wallet Transaction Service Test files:

`spec/lib/feature/wallet_transaction/`
* `create_tx.rb`
* `deposit.rb`
* `transfer.rb`
* `withdraw.rb`

Wallet Transaction Item Service Test file:

`spec/lib/feature/wallet_transaction_item/create_item_spec.rb`

## Future Consideration

If time and budget permitting, additional features could be added such as:
- End point API for transactions
- Adding merchant management
- Cashback and rewards
