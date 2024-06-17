# migrations/001_create_rodauth.rb
Sequel.migration do
  change do
    run 'PRAGMA foreign_keys = ON;'

    create_table :accounts do
      primary_key :id
      column :status, Integer, null: false, default: 1
      column :email, 'CITEXT', null: false
      index [:email], unique: true, where: "status IN (1, 2)"
      column :password_hash, String
    end

    create_table :account_password_change_times do
      primary_key :id
      column :account_id, Integer, null: false
      column :changed_at, DateTime, null: false, default: Sequel.lit('CURRENT_TIMESTAMP')

      foreign_key [:account_id], :accounts
    end
  end
end
