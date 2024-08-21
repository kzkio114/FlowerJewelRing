class AddDeviseToUsers < ActiveRecord::Migration[7.1]
  def up
    change_table :users do |t|
      ## Database authenticatable
      # t.string :email, null: false, default: ""  # ここがコメントアウトされていることを確認
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      # Indexes
      t.index :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
    end

    # add_index :users, :email, unique: true  # コメントアウトして問題を回避
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
    # add_index :users, :confirmation_token, unique: true
    # add_index :users, :unlock_token, unique: true
  end

  def down
    remove_column :users, :encrypted_password if column_exists?(:users, :encrypted_password)
    remove_column :users, :reset_password_token if column_exists?(:users, :reset_password_token)
    remove_column :users, :reset_password_sent_at if column_exists?(:users, :reset_password_sent_at)
    remove_column :users, :remember_created_at if column_exists?(:users, :remember_created_at)
    remove_column :users, :sign_in_count if column_exists?(:users, :sign_in_count)
    remove_column :users, :current_sign_in_at if column_exists?(:users, :current_sign_in_at)
    remove_column :users, :last_sign_in_at if column_exists?(:users, :last_sign_in_at)
    remove_column :users, :current_sign_in_ip if column_exists?(:users, :current_sign_in_ip)
    remove_column :users, :last_sign_in_ip if column_exists?(:users, :last_sign_in_ip)
  end
end
