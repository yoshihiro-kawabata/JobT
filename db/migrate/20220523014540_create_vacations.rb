class CreateVacations < ActiveRecord::Migration[6.0]
  def change
    create_table :vacations do |t|
      t.integer :paid_count
      t.integer :trans_count
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
