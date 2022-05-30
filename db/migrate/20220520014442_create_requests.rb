class CreateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :requests do |t|
      t.text :request_type, null: false
      t.date :period, null: false
      t.text :start_time
      t.text :end_time
      t.text :status
      t.text :reason, null: false
      t.text :create_name
      t.bigint :create_id, null: false
      t.boolean :consent_flg

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
