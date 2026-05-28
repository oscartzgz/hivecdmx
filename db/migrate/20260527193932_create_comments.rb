class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.string  :record_id, null: false
      t.bigint  :user_id,   null: false
      t.integer :status,    null: false, default: 0
      t.text    :body

      t.timestamps
    end

    add_index :comments, [ :record_id, :created_at ]
    add_foreign_key :comments, :users
  end
end
