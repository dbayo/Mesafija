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

    def getTipoCocina
        self.tipoCocina.where(:visible => true).order("orden ASC").collect(&:tipococina)
    end

    def getValoracion
    	self.restauranteOpiniones.select("SUM(cocina)/COUNT(*) AS sumcocina,SUM(ambiente)/COUNT(*) AS sumambiente,SUM(calidadprecio)/COUNT(*) AS sumcalidadprecio,SUM(servicio)/COUNT(*) AS sumservicio,SUM(limpieza)/COUNT(*) AS sumlimpieza")
    end

    def getValoracionMedia
    	self.getValoracion.collect{|rest| ( (rest.sumcocina.to_f + rest.sumambiente.to_f + rest.sumcalidadprecio.to_f + rest.sumservicio.to_f + rest.sumlimpieza.to_f)/ 5).round(2)}.first
    end

    def getDetailComentarios
        self.restauranteOpiniones.collect do |opinion|
            {
                "usuario" => opinion.restauranteUsuario.id_usuario,
                "fecha" => opinion.fecha,
                "valoracionMedia" => (opinion.cocina + opinion.ambiente + opinion.calidadprecio + opinion.servicio + opinion.limpieza) / 5,
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
        self.restaurantePromos.where("visible = true AND borrado = false AND fechainicio <= ? AND fechafin >= ?", Date.today, Date.today ).order("orden ASC").collect do |promo|
            {
                "idPromocion" => promo.idpromo,
                "titulo" => promo.nombre,
                "texto" => promo.descripcion,
                "disponibilidad" => promo.getDisponibilidad,
                "validez" => promo.fechafin,
                "img" => promo.getUrlImg,
            }
        end
    end

    def getRestauranteImages
        self.restauranteImg.where("activo = true AND archivo IS NOT NULL").collect{|img| img.getUrlImg}
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
