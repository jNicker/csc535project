class CreateChatUsers < ActiveRecord::Migration
  def change
    create_table :chat_users do |t|
      t.belongs_to :chat, index: true
      t.belongs_to :user, index: true
    end
    add_index :chat_users, [:chat_id, :user_id], :unique => true
  end
end
