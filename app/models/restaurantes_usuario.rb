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

	def getReservasPendientes
		Restaurante.find_by_sql("SELECT restaurantes.idrestaurante,restaurantes.visible,restaurantes.nombre,restaurantes_reservas.id_reserva,restaurantes_reservas.fecha_reserva,restaurantes_reservas.hora_reserva,restaurantes_reservas.usuario,restaurantes_reservas.promocion,restaurantes_opiniones.comentario,
			(SELECT restaurantes_img.archivo FROM restaurantes_img WHERE restaurantes_img.restaurante=restaurantes.idrestaurante AND activo=1 ORDER BY orden LIMIT 0,1) AS archivo,
			(SELECT nombre FROM restaurantes_usuarios WHERE id_usuario=?) AS usuario_nombre,
			(SELECT apellidos FROM restaurantes_usuarios WHERE id_usuario=?) AS usuario_apellidos,
			(SELECT (SUM(cocina)+SUM(ambiente)+SUM(calidadprecio)+SUM(servicio)+SUM(limpieza))/5/COUNT(*) FROM restaurantes_opiniones WHERE restaurantes_opiniones.restaurante=restaurantes.idrestaurante) AS nota
			JOIN restaurantes_reservas ON restaurantes_reservas.restaurante=restaurantes.idrestaurante 
			LEFT JOIN restaurantes_opiniones ON restaurantes_reservas.id_reserva=restaurantes_opiniones.reserva 
			WHERE restaurantes_reservas.cancelado='0'
			and LOCATE(CONCAT(',',restaurantes_reservas.usuario,','),'$usuarios')>0
			and fecha_reserva>='$hoy'
			order by fecha_reserva asc
			", self.id_usuario, self.id_usuario).count
	end

	def getReservasRealizadas
		Restaurante.find_by_sql("SELECT restaurantes.idrestaurante,restaurantes.visible,restaurantes.nombre,restaurantes_reservas.id_reserva,restaurantes_reservas.fecha_reserva,restaurantes_reservas.usuario,restaurantes_opiniones.comentario,
			(SELECT restaurantes_img.archivo FROM restaurantes_img WHERE restaurantes_img.restaurante=restaurantes.idrestaurante AND activo=1 ORDER BY orden LIMIT 0,1) AS archivo,
			(SELECT (SUM(cocina)+SUM(ambiente)+SUM(calidadprecio)+SUM(servicio)+SUM(limpieza))/5/COUNT(*) FROM restaurantes_opiniones WHERE restaurantes_opiniones.restaurante=restaurantes.idrestaurante) AS nota
			JOIN restaurantes_reservas ON restaurantes_reservas.restaurante=restaurantes.idrestaurante 
			LEFT JOIN restaurantes_opiniones ON restaurantes_reservas.id_reserva=restaurantes_opiniones.reserva 
			WHERE restaurantes_reservas.cancelado='0'
			and LOCATE(CONCAT(',',restaurantes_reservas.usuario,','),'$usuarios')>0
			and fecha_reserva<'$hoy'
			order by fecha_reserva desc
			", self.id_usuario, self.id_usuario).count
	end

	def getNumComentariosRealizados
		0
	end

	def getFavoritos

	end
end
