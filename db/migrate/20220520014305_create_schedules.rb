class CreateSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :schedules do |t|
      t.date :schedule_date, null: false
      t.text :start_time
      t.text :end_time
      t.text :status
      t.references :user, null: false, foreign_key: true
      t.integer :group
      t.boolean :offday, null: false, default: false 
      t.text :comment

      t.timestamps
    end
  end
end
