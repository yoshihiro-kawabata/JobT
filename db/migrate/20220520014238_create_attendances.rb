class CreateAttendances < ActiveRecord::Migration[6.0]
  def change
    create_table :attendances do |t|
      t.date :attendance_date, null: false
      t.text :start_time
      t.text :end_time
      t.references :user, null: false, foreign_key: true
      t.integer :group
      t.boolean :edit_flg, null: false, default: false 
      t.text :comment

      t.timestamps
    end
  end
end
