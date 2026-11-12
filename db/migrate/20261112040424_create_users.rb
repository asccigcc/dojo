class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :users, "lower(name)", unique: true, name: "index_users_on_lower_name"
  end
end
