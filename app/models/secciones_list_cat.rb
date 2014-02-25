class SeccionesListCat < ActiveRecord::Base
    self.table_name = 'secciones_list_cat'
    self.primary_key = :idcategoria

    def getListadoPreguntas
    	result = []
    	SeccionesList.order("orden ASC").where(:categoria => self.idcategoria, :activo => true).each do |pregunta|
    		result << {
    			"idPregunta" => pregunta.idlistado,
    			"pregunta" => pregunta.tituloes,
    			"respuesta" => pregunta.textoes
    		}
    	end
    	return result
    end
end
