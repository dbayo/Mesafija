xml.instruct!
xml.restaurante do
	xml.plazasmax @plazasmax
	xml.horas do
		@result.each do |plaza|
			xml.hora do
				xml.hora plaza.keys.first
				xml.disponible plaza.values.first
			end
		end
	end
end