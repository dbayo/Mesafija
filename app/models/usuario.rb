class Usuario < ActiveRecord::Base
	has_many :restauranteUsuarios, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'RestaurantesUsuario'
end
