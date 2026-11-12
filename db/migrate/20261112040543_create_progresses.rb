class CreateProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :progresses do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :exercise, null: false, foreign_key: { on_delete: :cascade }
      t.integer :unlocked_part, null: false, default: 1
      t.integer :interval_index
      t.datetime :next_review_at
      t.string :last_result
      t.integer :passes_count, null: false, default: 0
      t.datetime :last_attempted_at

      t.timestamps
    end
    add_index :progresses, %i[user_id exercise_id], unique: true
    add_index :progresses, %i[user_id next_review_at]
  end
end
