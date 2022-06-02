class CreateConsents < ActiveRecord::Migration[6.0]
  def change
    create_table :consents do |t|
      t.text :request_content
      t.boolean :request_flg
      t.integer :group
      t.string :name

      t.references :user, null: false, foreign_key: true
      t.bigint :request_id, null: false

      t.timestamps
    end
  end
end
