class Zona < ActiveRecord::Base
    self.primary_key = :idzona
    belongs_to :restaurante
end
