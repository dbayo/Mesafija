class RestaurantesUsuario < ActiveRecord::Base
    self.primary_key = :id_usuario
    belongs_to :restaurante, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'Restaurante'

    def getTipoUsuario
    	# (SELECT count(*) FROM restaurantes_reservas WHERE usuario=restaurantes_usuarios.id_usuario and cancelado=0 and fecha_reserva<'$hoy') AS numreservas
    	numReservas = RestaurantesReserva.where("usuario = ? && cancelado = ? && fecha_reserva < ?", self.id_usuario, 0, Time.now).count
		if numReservas > 15
			return "PREMIUM"
		elsif numReservas > 5
			return "MASTER"
		else
			return "NOVEL"
		end
	end
end
