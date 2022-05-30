class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.integer :number
      t.string :name

      t.timestamps
    end
  end
end
