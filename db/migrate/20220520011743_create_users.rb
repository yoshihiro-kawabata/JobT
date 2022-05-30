class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.integer :number, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :admin, null: false, default: false 
      t.integer :templete
      t.integer :group
      t.timestamps
    end
  end
end
