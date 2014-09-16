xml.instruct!
xml.restaurantes do
	@result.each do |restaurante|
		xml.restaurante do
			xml.id_restaurante restaurante["id_restaurante"]
			xml.nombre restaurante["nombre"]
			xml.ciudad restaurante["ciudad"]
			xml.zona restaurante["zona"]
			xml.valoracion restaurante["valoracion"]
			xml.numero_comentarios restaurante["numero_comentarios"]
			xml.url_imagenes do
				restaurante["url_imagen"].each do |url_imagen|
					xml.url_imagen url_imagen
				end
			end
		end
	end
end