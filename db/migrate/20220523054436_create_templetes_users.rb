class CreateTempletesUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :templetes_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :templete, null: false, foreign_key: true

      t.timestamps
    end
  end
end
