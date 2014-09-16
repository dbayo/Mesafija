xml.instruct!
xml.categorias do
	@result.each do |result|
		xml.categoria do
			xml.tituloCategoria result["nombre"]
			xml.listaPreguntas do
				result["listadoPreguntas"].each do |pregunta|
					xml.pregunta do
						xml.pregunta pregunta["pregunta"]
						xml.respuesta pregunta["respuesta"]
					end
				end
			end
		end
	end
end