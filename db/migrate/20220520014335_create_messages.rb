class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.text:content
      t.text :create_name
      t.bigint :create_id
      t.text :user_name
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
