class Restaurante < ActiveRecord::Base
    self.primary_key = :idrestaurante
    belongs_to :zona, :foreign_key => 'zona', :primary_key => 'idzona', :class_name => 'Zona'
    belongs_to :ciudad, :foreign_key => 'ciudad', :primary_key => 'idciudad', :class_name => 'Ciudade'
    has_many :restauranteOpiniones, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'RestaurantesOpinione'
    has_many :restauranteImg, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'RestaurantesImg'
    has_many :asgTiposCocina, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'AsgTiposCocina'
    has_many :tipoCocina, :through => :asgTiposCocina, :source => :tiposCocina
    has_many :restauranteUsuarios, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'RestaurantesUsuario'
    has_many :restaurantePromos, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'RestaurantesPromo'

    def getValoracion
    	self.restauranteOpiniones.select("SUM(cocina)/COUNT(*) AS sumcocina,SUM(ambiente)/COUNT(*) AS sumambiente,SUM(calidadprecio)/COUNT(*) AS sumcalidadprecio,SUM(servicio)/COUNT(*) AS sumservicio,SUM(limpieza)/COUNT(*) AS sumlimpieza")
    end

    def getValoracionMedia
    	self.getValoracion.collect{|rest| (rest.sumcocina + rest.sumambiente + rest.sumcalidadprecio + rest.sumservicio + rest.sumlimpieza)/ 5}
    end

    def getDetailComentarios
        result = []
        self.restauranteOpiniones.each do |opinion|
            result << {
                "usuario" => opinion.restauranteUsuario.id_usuario,
                "tipoUsuario" => opinion.restauranteUsuario.getTipoUsuario,
                "fecha" => opinion.fecha,
                "valoracionCocina" => opinion.cocina,
                "valoracionAmbiente" => opinion.ambiente,
                "valoracionCalidadPrecio" => opinion.calidadprecio,
                "valoracionServicio" => opinion.servicio,
                "valoracionLimpieza" => opinion.limpieza,
                "comentario" => opinion.comentario
            }
        end
    end

    def getDetailPromociones
        result = []
        self.restaurantePromos.each do |promo|
            result << {
                "idPromocion" => promo.idpromo,
                "titulo" => promo.nombre,
                "texto" => promo.descripcion,
                # TODO : Falta hacer la disponibilidad
                "disponibilidad" => "",
                "validez" => promo.fechafin
            }
        end
    end

    def self.getTurno(turno_id)
        case turno_id
        when 1
            "break"
        when 2
            "almuerzo"
        when 3
            "onces"
        when 4
            "cena"
        else
            ""
        end
    end
end
