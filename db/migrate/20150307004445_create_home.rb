class CreateHome < ActiveRecord::Migration
  def change
    create_table :homes do |t|
      t.string :body
      t.timestamps
    end
  end
end
