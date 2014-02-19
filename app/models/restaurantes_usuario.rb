class RestaurantesUsuario < ActiveRecord::Base
    self.primary_key = :id_usuario
    belongs_to :restaurante, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'Restaurante'
end
