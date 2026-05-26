class CreateRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :records, id: :string do |t|
      t.string  :room,        null: false
      t.string  :category,    null: false
      t.string  :item,        null: false
      t.string  :owner
      t.integer :status,      null: false, default: 0
      t.text    :note
      t.string  :inspector
      t.date    :report_date, null: false
      t.references :user,     foreign_key: true, null: true

      t.timestamps
    end

    add_index :records, :room
    add_index :records, :status
    add_index :records, :report_date
    add_index :records, [ :room, :category ], name: "index_records_on_room_and_category"
  end
end
