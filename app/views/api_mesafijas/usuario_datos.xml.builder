xml.instruct!
xml.restaurante do
	xml.id_restaurante @result["id_restaurante"]
	xml.nombre @result["nombre"]
	xml.latitud @result["latitud"]
	xml.longitud @result["longitud"]
	xml.direccion @result["direccion"]
	xml.ciudad @result["ciudad"]
	xml.zona @result["zona"]
	xml.tipoCocina @result["tipoCocina"]
	xml.descripcion @result["descripcion"]
	xml.otras_informaciones @result["otras_informaciones"]
	xml.valoracion_media @result["valoracion_media"]
	xml.comentarios do
		@result["comentarios"].each do |comentario|
			xml.comentario do
				xml.usuario comentario["usuario"]
				xml.fecha comentario["fecha"]
				xml.valoracionMedia comentario["valoracionMedia"]
				xml.valoracionCocina comentario["valoracionCocina"]
				xml.valoracionAmbiente comentario["valoracionAmbiente"]
				xml.valoracionCalidadPrecio comentario["valoracionCalidadPrecio"]
				xml.valoracionServicio comentario["valoracionServicio"]
				xml.valoracionLimpieza comentario["valoracionLimpieza"]
				xml.descripcion comentario["comentario"]
			end
		end
	end
	xml.promociones @result["promociones"]
	xml.url_imagenes do
		@result["url_imagen"].each do |url_imagen|
			xml.url_imagen url_imagen
		end
	end
end
