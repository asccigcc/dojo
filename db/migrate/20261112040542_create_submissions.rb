class CreateSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :submissions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :exercise, null: false, foreign_key: { on_delete: :cascade }
      t.integer :part_number, null: false, default: 1
      t.text :code, null: false, default: ""
      t.string :status, null: false, default: "pending"
      t.text :output
      t.json :failure_details, null: false, default: []
      t.integer :runs, null: false, default: 0
      t.integer :assertions, null: false, default: 0
      t.integer :failures_count, null: false, default: 0
      t.integer :errors_count, null: false, default: 0
      t.integer :skips, null: false, default: 0
      t.integer :duration_ms

      t.timestamps
    end
    add_index :submissions, %i[user_id exercise_id created_at]
    add_index :submissions, %i[user_id status created_at]
  end
end
