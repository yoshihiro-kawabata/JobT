class CreateDocumentsRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :documents_requests do |t|
      t.references :document, null: false, foreign_key: true
      t.references :request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
