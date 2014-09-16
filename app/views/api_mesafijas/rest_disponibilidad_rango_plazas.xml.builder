xml.instruct!
xml.restaurante do
	xml.plazasmax @plazasmax
	xml.plazas do
		@result.each do |plaza|
			xml.plaza do
				xml.comensales plaza.keys.first
				xml.disponible plaza.values.first
			end
		end
	end
end