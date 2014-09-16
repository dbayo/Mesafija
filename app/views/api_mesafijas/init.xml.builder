xml.instruct!
xml.categoria do
	xml.ciudades do
		@ciudades.each do |ciudad|
			xml.ciudad do
				xml.id ciudad.idciudad
				xml.nombre ciudad.ciudad
			end
		end
	end

	xml.zonas do
		@zonas.each do |zona|
			xml.zona do
				xml.id zona.idzona
				xml.nombre zona.zona
			end
		end
	end

	xml.tipoCocina do
		@tipoCocinas.each do |tipoCocina|
			xml.tipoCocina do
				xml.id tipoCocina.idtipococina
				xml.nombre tipoCocina.tipococina
			end
		end
	end

	xml.cortesPrecio do
		@cortesPrecio.each do |cortePrecio|
			xml.cortePrecio do
				xml.id cortePrecio.idrangoprecio
				xml.nombre cortePrecio.rangoprecio
			end
		end
	end

	xml.medios do
		@medios.each do |medio|
			xml.medio do
				xml.id medio.idmedio
				xml.nombre medio.medio
			end
		end
	end
end