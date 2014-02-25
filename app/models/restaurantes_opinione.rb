class RestaurantesOpinione < ActiveRecord::Base
    self.primary_key = :idopinion
    belongs_to :restaurante, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'Restaurante'
    belongs_to :restauranteUsuario, :foreign_key => 'usuario', :primary_key => 'id_usuario', :class_name => 'RestaurantesUsuario'

end
