class ApiMesafijasController < ApplicationController
  before_filter :default_format_json
  respond_to :xml, :json

  # Servicio utilizado para conseguir los valores de inicialización de mesafija.com
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
    restaurante = Restaurante.where(:idrestaurante => params[:id]).first
    respond_with(nil) and return if restaurante.nil?
    result = {
      "id_restaurante" => restaurante.idrestaurante,
      "latitud" => restaurante.lat,
      "longitud" => restaurante.lng,
      "direccion" => restaurante.direccion,
      "ciudad" => !restaurante.ciudad.blank? ? restaurante.ciudad.ciudad : "",
      "zona" => !restaurante.zona.blank? ? restaurante.zona.zona : "",
      "tipoCocina" => restaurante.tipoCocina,
      "descripcion" => restaurante.txtpresentacion,
      "detalle" => restaurante.txtotros,
      "valoracion_media" => restaurante.getValoracionMedia,
      "numero_comentarios" => restaurante.restauranteOpiniones.count,
      "numero_usuario" => restaurante.restauranteUsuarios.count,
      "tipoUsuario" => "???",
      "fecha" => restaurante.fecha_alta,
      "valoracion" => restaurante.getValoracion,
      "comentario" => restaurante.restauranteOpiniones.count,
      "promociones" => restaurante.restaurantePromos,
      "idPromocion" => restaurante.restaurantePromos.last.idpromo,
      "titulo" => restaurante.nombre,
      "texto" => restaurante.txtpresentacion,
      "disponibilidad" => "",
      "validez" => "",
      "url_imagen" => restaurante.restauranteImg
    }

    respond_with(result)
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
    rest_reserva = RestaurantesReserva.where(:id_reserva => params[:id])
    if rest_reserva.exists?
      rest_reserva.first.update_attributes(:cancelado => 1)
      respond_with(true)
    else
      respond_with(false)
    end
  end

  # Servicio que permite el reconocimiento del usuario
  def usuario_login
    respond_with(false) and return if params[:email].blank? || params[:password].blank?
    user = Usuario.where(:email => params[:email], :password => OpenSSL::HMAC.hexdigest('sha256', params[:password], 'colombia'))

    if user.exists?
      respond_with(user.first.idreg)
    else
      respond_with(false)
    end
  end

  # Servicio que permite procesar la regeneración de password del usuario
  def usuario_regpswd
    email = params[:email]
    clave = SecureRandom.hex(40)
    usuario = Usuario.where(:email => params[:email]).first

    if usuario.exists?
      usuarioReg = UsuariosReg.create(:email => usuario.email, :clave => clave)

      ApiMesafijaMailer.usuario_regpswd(usuarioReg).deliver
      respond_with("Aceptado - Te hemos enviado un email")
    else
      respond_with("Denegado - Email not valid")
    end
  end

  # Servicio que permite el registro del usuario
  def usuario_registro
    if params[:nombre].blank? 
      respond_with("Denegado - Falta nombre") and return
    elsif params[:apellidos].blank? 
      respond_with("Denegado - Falta apellidos") and return
    elsif params[:telefono].blank? 
      respond_with("Denegado - Falta telefono") and return
    elsif params[:ciudad].blank? 
      respond_with("Denegado - Falta ciudad") and return
    elsif params[:email].blank? 
      respond_with("Denegado - Falta email") and return
    elsif params[:password].blank? 
      respond_with("Denegado - Falta password") and return
    elsif RestaurantesUsuario.where(:email => params[:email])
      respond_with("Denegado - Usuario ya existe")
    end

    restauranteUsuario = RestaurantesUsuario.create(:fecha => Time.now.strftime("%F"), :hora => Time.now.strftime("%T"), :nombre => params[:nombre], :apellidos => params[:apellidos], :telefono => params[:telefono], :ciudad => params[:ciudad], :medio => params[:medio], :email => params[:email], :password => OpenSSL::HMAC.hexdigest('sha256', params[:password], 'colombia') )

    if restauranteUsuario.exists?
      respond_with(restauranteUsuario.first.id_usuario)
    else
      respond_with(false)
    end
  end

  # Servicio que permite acceder a los datos de usuario
  def usuario_datos

  end

  # Servicio que permite editar los datos de usuario mediante los datos proporcionados con el servicio usuario-datos.php
  def usuario_editar
    restauranteUsuario = RestaurantesUsuario.where(:id_usuario => params[:id]).first

    respond_with("Denegado - No existe el usuario con id : "+params[:id]) and return if restauranteUsuario.nil?

    restauranteUsuario.update_attributes(:nombre => params[:nombre]) unless params[:nombre].blank?
    restauranteUsuario.update_attributes(:apellidos => params[:apellidos]) unless params[:apellidos].blank?
    restauranteUsuario.update_attributes(:telefono => params[:telefono]) unless params[:telefono].blank?
    restauranteUsuario.update_attributes(:ciudad => params[:ciudad]) unless params[:ciudad].blank?
    restauranteUsuario.update_attributes(:email => params[:email]) unless params[:email].blank?
    respond_with("Aceptado - Usuario actualizado")
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
      request.format = "xml" if params[:output] == "xml"
    end
end
