class CreateTempletes < ActiveRecord::Migration[6.0]
  def change
    create_table :templetes do |t|
      t.string :name, null: false
      t.text :start_time
      t.text :end_time
      t.timestamps
    end
  end
end
