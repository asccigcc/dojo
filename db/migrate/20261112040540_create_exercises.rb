class CreateExercises < ActiveRecord::Migration[8.1]
  def change
    create_table :exercises do |t|
      t.string :slug, null: false
      t.string :kind, null: false
      t.string :language, null: false, default: "ruby"
      t.string :category, null: false
      t.string :title, null: false
      t.integer :position, null: false
      t.integer :parts_count, null: false, default: 1
      t.text :description_md, null: false, default: ""
      t.text :starter_code, null: false, default: ""
      t.text :prelude_code, null: false, default: ""
      t.text :test_code
      t.text :solution_code, null: false, default: ""
      t.text :expected_code
      t.text :notes_md
      t.string :code_path
      t.string :test_path

      t.timestamps
    end
    add_index :exercises, :slug, unique: true
    add_index :exercises, %i[kind position]
  end
end
