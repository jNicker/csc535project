class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :body
      t.belongs_to :chat, index: true
      t.belongs_to :user, index: true
      t.timestamps
    end
  end
end
