class CreateReports < ActiveRecord::Migration[6.0]
  def change
    create_table :reports do |t|
      t.text :daytask
      t.text :emotion
      t.text :learn
      t.text :transition
      t.text :admincom
      t.references :user, null: false, foreign_key: true
      t.text :user_name
      t.integer :group
      t.text :createdate

      t.timestamps
    end
  end
end
