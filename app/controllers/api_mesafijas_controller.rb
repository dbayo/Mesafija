class ApiMesafijasController < ApplicationController
  before_filter :default_format_json
  respond_to :xml, :json

  # Servicio utilizado para conseguir los valores de inicialización de mesafija.com
  def init
    
  end

  # Servicio que suministra el listado de restaurantes con sus datos básicos
  def rest_lista
    restaurantes = Restaurante.all
    restaurantes = restaurantes.where(:zona => params[:zona]) unless params[:zona].blank?
    restaurantes = restaurantes.where(:ciudad => params[:ciudad]) unless params[:ciudad].blank?
    restaurantes = restaurantes.join(:tipoCocina).where("" => params[:tipoCocina]) unless params[:tipoCocina].blank?
    restaurantes = restaurantes.where(:idrestaurante => params[:id]) unless params[:id].blank?
    restaurantes = restaurantes.order(:fecha_alta)

    # Obtener valoracion total
    result = []
    restaurantes.each do |restaurante|
      result << {
        "id_restaurante" => restaurante.id,
        "nombre" => restaurante.nombre,
        "ciudad" => restaurante.ciudad.ciudad,
        "zona" => !restaurante.zona.blank? ? restaurante.zona.zona : "",
        "valoracion" => RestaurantesOpinione.select("SUM(cocina)/COUNT(*) AS sumcocina,SUM(ambiente)/COUNT(*) AS sumambiente,SUM(calidadprecio)/COUNT(*) AS sumcalidadprecio,SUM(servicio)/COUNT(*) AS sumservicio,SUM(limpieza)/COUNT(*) AS sumlimpieza")
                                            .where(:restaurante => restaurante.id),
        "numero_comentarios" => restaurante.restauranteOpiniones.count,
        "url_imagen" => restaurante.restauranteImg
      }
    end

    case params[:ordenacion]
    when 'nom'
      result.sort_by{ |k, v| k[:nombre] }
    when 'val'
      result.sort_by { |k, v| k[:valoracion][:sumcocina].to_i + k[:valoracion][:sumambiente].to_i + k[:valoracion][:sumcalidadprecio].to_i + k[:valoracion][:sumservicio].to_i + k[:valoracion][:sumlimpieza].to_i}
    when 'res'
      result.sort_by{ |k, v| k[:nombre] }
    end unless params[:ordenacion].blank?

    result.reverse if !params[:orden].blank? && params[:orden] == "asc"

    respond_with(result)
  end

  # Servicio que suministra el detalle de restaurante
  def rest_datos
    restaurantes = Restaurante.select(:idrestaurante, :nombre, :fciudad).where(:ciudad => 12)
  end

  # Servicio que suministra la disponibilidad del restaurante. Si solicitamos solamente fecha nos devolverá 
  # el rango de plazas disponible. Si suministramos además el número de comensales, nos devolverá los 
  # horarios disponibles para la fecha y número de comensales seleccionados
  def rest_disponibilidad

  end

  # Servicio que permite reservar mediante los datos proporcionados con los servicios rest- 
  # disponibilidad.php y usuario-datos.php
  def rest_reserva_agregar

  end

  # Servicio que permite cancelar una reserva mediante los datos proporcionados con el servicio usuario-datos.php
  def rest_reserva_cancelar

  end

  # Servicio que permite el reconocimiento del usuario
  def usuario_login

  end

  # Servicio que permite procesar la regeneración de password del usuario
  def usuario_regpswd

  end

  # Servicio que permite el registro del usuario
  def usuario_registro

  end

  # Servicio que permite acceder a los datos de usuario
  def usuario_datos

  end

  # Servicio que permite editar los datos de usuario mediante los datos proporcionados con el servicio usuario-datos.php
  def usuario_editar

  end

  # Servicio que permite valorar un restaurante por el usuario mediante los datos proporcionados con el servicio usuario-datos.php
  def valoracion

  end

  # Servicio que permite marcar un restaurante como favorito por el usuario mediante los datos proporcionados con el servicio usuario-datos.php
  def usuario_favorito_agregar

  end

  # Servicio que permite desmarcar un restaurante como favorito por el usuario mediante los datos proporcionados con el servicio usuario-datos.php
  def usuario_favorito_eliminar

  end

  # Servicio que permite listar todas las preguntas frecuentes
  def preguntas

  end




  def getAllUsers
    respond_with(@users = User.first)
  end

  private
    def default_format_json
      request.format = "json"
      request.format = "xml" if params[:format] == "xml"
    end
end
