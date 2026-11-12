class CreateParts < ActiveRecord::Migration[8.1]
  def change
    create_table :parts do |t|
      t.references :exercise, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.integer :number, null: false
      t.text :description_md, null: false, default: ""

      t.timestamps
    end
    add_index :parts, %i[exercise_id number], unique: true
  end
end
