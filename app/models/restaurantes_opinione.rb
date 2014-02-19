class RestaurantesOpinione < ActiveRecord::Base
    self.primary_key = :idopinion
    belongs_to :restaurante, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'Restaurante'

end
