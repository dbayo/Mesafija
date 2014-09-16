xml.instruct!
xml.restaurante do
	xml.plazasmax @plazasmax
	xml.turnos do
		@result.each do |plaza|
			xml.turno do
				xml.nombre plaza.keys.first
				xml.disponible plaza.values.first
			end
		end
	end
end