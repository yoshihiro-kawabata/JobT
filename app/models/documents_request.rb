class DocumentsRequest < ApplicationRecord
  belongs_to :document
  belongs_to :request
end
