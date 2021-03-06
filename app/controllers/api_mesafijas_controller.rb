class ApiMesafijasController < ApplicationController
  include ActionController::MimeResponds
  include ActionController::ImplicitRender
  before_filter :default_format_xml
  before_filter :check_idCliente
  respond_to :xml, :json

  # Servicio utilizado para conseguir los valores de inicialización de mesafija.com
  def init
    result = []
    @ciudades = Ciudade.where(:visible => true)
    @zonas = Zona.where(:visible => true)
    @tipoCocinas = TiposCocina.where(:visible => true).order("orden ASC")
    @cortesPrecio = RangosPrecio.where(:visible => true).order("orden ASC")
    @medios = Medio.where(:visible => true, :borrado => false).order("orden ASC")

    respond_with do |format|
      format.json { render json: result }
      format.xml { render '/app/views/api_mesafijas/init.xml.builder' }
    end
  end

  # result = []
  #   result << {
  #     "Ciudades" => Ciudade.where(:visible => true).map{|ciudad| {"id" => ciudad.idciudad, "nombre" => ciudad.ciudad} }
  #   }
  #   result << {
  #     "Zonas" => Zona.where(:visible => true).map{|zona| {"id" => zona.idzona, "nombre" => zona.zona} }
  #   }
  #   result << {
  #     "TipoCocina" => TiposCocina.where(:visible => true).order("orden ASC").map{|tipoCocina| {"id" => tipoCocina.idtipococina, "nombre" => tipoCocina.tipococina} }
  #   }
  #   result << {
  #     "CortesPrecio" => RangosPrecio.where(:visible => true).order("orden ASC").map{|cortePrecio| {"id" => cortePrecio.idrangoprecio, "nombre" => cortePrecio.rangoprecio} }
  #   }
  #   result << {
  #     "Medios" => Medio.where(:visible => true, :borrado => false).order("orden ASC").map{|medio| {"id" => medio.idmedio, "nombre" => medio.medio} }
  #   }

  # Servicio que suministra el listado de restaurantes con sus datos básicos
  def rest_lista
    restaurantes = Restaurante.where(:visible => true)
    restaurantes = restaurantes.where(:zona => params[:zona]) unless params[:zona].blank?
    restaurantes = restaurantes.where(:ciudad => params[:ciudad]) unless params[:ciudad].blank?
    restaurantes = restaurantes.joins(:asgTiposCocina).where("asg_tipos_cocina.tipoCocina = ?", params[:tipoCocina]) unless params[:tipoCocina].blank?
    restaurantes = restaurantes.where(:idrestaurante => params[:id]) unless params[:id].blank?
    # TODO: "falta el corte precio"
    restaurantes = restaurantes.order(:nombre)

    @result = []
    restaurantes.each do |restaurante|
      @result << {
        "id_restaurante" => restaurante.id,
        "nombre" => restaurante.nombre,
        "ciudad" => restaurante.ciudad.ciudad,
        "zona" => !restaurante.zona.blank? ? restaurante.zona.zona : "",
        "valoracion" => restaurante.getValoracionMedia,
        "numero_comentarios" => restaurante.restauranteOpiniones.count,
        "url_imagen" => restaurante.getRestauranteImages
      }
    end

    if !params[:ordenacion].blank? && params[:ordenacion] == 'val'
      @result.sort_by { |k, v| k[:valoracion][:sumcocina].to_i + k[:valoracion][:sumambiente].to_i + k[:valoracion][:sumcalidadprecio].to_i + k[:valoracion][:sumservicio].to_i + k[:valoracion][:sumlimpieza].to_i}
    end

    @result.reverse if !params[:orden].blank? && params[:orden] == "asc"

    respond_with do |format|
      format.json { render json: @result }
      format.xml { render '/app/views/api_mesafijas/rest_lista.xml.builder'  }
    end
  end

  # Servicio que suministra el detalle de restaurante
  def rest_datos
    restaurante = Restaurante.where(:idrestaurante => params[:idRestaurante]).first
    showError("No existe el restaurante") and return if restaurante.nil?
    @result = {
      "id_restaurante" => restaurante.idrestaurante,
      "nombre" => restaurante.nombre,
      "latitud" => restaurante.lat,
      "longitud" => restaurante.lng,
      "direccion" => restaurante.direccion,
      "ciudad" => !restaurante.ciudad.blank? ? restaurante.ciudad.ciudad : "",
      "zona" => !restaurante.zona.blank? ? restaurante.zona.zona : "",
      "tipoCocina" => restaurante.getTipoCocina,
      "descripcion" => restaurante.txtpresentacion,
      "otras_informaciones" => restaurante.txtotros,
      "valoracion_media" => restaurante.getValoracionMedia,
      "comentarios" => restaurante.getDetailComentarios,
      "promociones" => restaurante.getDetailPromociones,
      "url_imagen" => restaurante.getRestauranteImages
    } unless restaurante.nil?

    respond_to do |format|
      format.json { render json: @result }
      format.xml { render '/app/views/api_mesafijas/rest_datos.xml.builder' }
    end
  end

  # Muestra los dias del calendario que puede elegir
  # ?idRestaurante=126&mes=3&anyo=2014
  def rest_disponibilidad_calendario
    @restaurante = Restaurante.where(:idrestaurante => params[:idRestaurante]).first
    showError("No existe el restaurante") and return if restaurante.nil?

    @mes = params[:mes].to_i
    showError("Falta el mes") and return if restaurante.nil?

    @anyo = params[:anyo].to_i
    showError("Falta el año") and return if restaurante.nil?

    @hoy = Time.zone.now.strftime("%F")
    @fecha = Time.zone.parse(@anyo.to_s+"-"+@mes.to_s+"-"+"1")

    @promo = RestaurantesPromo.where(:idpromo => params[:idPromocion]).first unless params[:idPromocion].blank?
    (@promo.blank?) ? @idPromocion = "0" : @idPromocion = @promo.id.to_s

    # TODO : Falta promo

    # Mes y año del mes anterior
    @mesant = @mes - 1
    @anyoant = @anyo
    if @mesant == 0
      @anyoant -= 1
      @mesant = 12
    end

    # Mes y año del mes siguiente
    @messig = @mes + 1
    @anyosig = @anyo
    if @messig == 13
      @anyosig += 1
      @messig = 1
    end

    # Obtenemos la posición del primer día del mes en curso
    @posdia = @fecha.beginning_of_month.mday
    # Número de días del mes en curso
    @diasmes = @fecha.end_of_month.mday

    # Nombre del mes en curso
    if @mes == 1 then @txtmes = 'Enero'
    elsif @mes == 2 then @txtmes = 'Febrero'
    elsif @mes == 3 then @txtmes = 'Marzo'
    elsif @mes == 4 then @txtmes = 'Abril'
    elsif @mes == 5 then @txtmes = 'Mayo'
    elsif @mes == 6 then @txtmes = 'Junio'
    elsif @mes == 7 then @txtmes = 'Julio'
    elsif @mes == 8 then @txtmes = 'Agosto'
    elsif @mes == 9 then @txtmes = 'Septiembre'
    elsif @mes == 10 then @txtmes = 'Octubre'
    elsif @mes == 11 then @txtmes = 'Noviembre'
    elsif @mes == 12 then @txtmes = 'Diciembre'
    end

    # Tiempos x mesa
    if @modoreservas == 0
      restaurantesTiempos = RestaurantesTiempo.select("least(tiempo_1,tiempo_2,tiempo_3,tiempo_4,tiempo_5,tiempo_6,tiempo_7,tiempo_8,tiempo_9,tiempo_10,tiempo_grupos) as tiempo_minimo").where(:restaurante => @restaurante.id).first
      @tiempo_minimo = restaurantesTiempos.tiempo_minimo.hour.hour + restaurantesTiempos.tiempo_minimo.min.minutes

      restaurantesTiempos = RestaurantesTiempo.where(:restaurante => @restaurante.id).first
      @bloques_nec = (restaurantesTiempos.tiempo_grupos.hour.hour + restaurantesTiempos.tiempo_grupos.min.minutes) / 1800
    end

    # TODO: Para que sirve bloqueo dia? => El mismo dia no se puede reservar
    @bloqueo_dia = @restaurante.bloqueo_dia
    # TODO: margen_reserva se utiliza en el codigo PHP ?
    @margen_reserva = @restaurante.margen_reserva.hour.hour + @restaurante.margen_reserva.min.minutes
    @bloqueo_hora = (Time.zone.now + @margen_reserva).to_i

    @consultas = 0
    result = Array.new

    (1..@diasmes).each do |i|
      @fechacal = @fecha.change({:day => i})
      if @fechacal < @hoy
        result << {i => false}
      elsif @idPromocion.to_i > 0 && @fechacal < @fechapromoinicio
        result << {i => false}
      elsif @idPromocion.to_i > 0 && @fechacal > @fechapromofin
        result << {i => false}
      elsif @fechacal == @hoy && @bloqueo_dia == 1
        result << {i => false}
      else
        # Calculo letra dia semana
        # TODO : Hacer todo el calculo interno
        result << {i => true}
      end
    end

    # byebug

    respond_with(result)

  end

  # Servicio que suministra la disponibilidad del restaurante. Si solicitamos solamente fecha nos devolverá
  # el rango de plazas disponible.
  def rest_disponibilidad_rango_plazas
    # Buscar en include-reservas-personas.php, en if($modoreservas==1){
    # idRestaurante=126&fecha=2014-01-16

    @restaurante = Restaurante.where(:idrestaurante => params[:idRestaurante]).first
    showError("No existe el restaurante") and return if @restaurante.nil?

    showError("Falta la fecha. El formato de la fecha es “AAAA-MM-DD” ie: 2014-01-16") and return if params[:fecha].blank?
    @fecha = Time.zone.parse(params[:fecha])
    @fecha = Time.zone.now if @fecha.blank?
    @letraDia = getLetraDia(@fecha)

    @promo = RestaurantesPromo.where(:idpromo => params[:idPromocion]).first unless params[:idPromocion].blank?
    (@promo.blank?) ? @idPromocion = "0" : @idPromocion = @promo.id.to_s

    @modoreservas = @restaurante.modoreservas

    # Aperturas en promo
    aperturaPromo

    # TODO: plazasmin se utiliza en el codigo PHP ?
    # Minimo plazas restaurante
    @plazasmin = getMinimoPlazasRestaurante

    # Maximo plazas restaurante
    @plazasmax = getMaximoPlazasRestaurante

    # Tiempos x mesa
    tiempoPorMesaPersonas

    # TODO: Para que sirve bloqueo dia?
    @bloqueo_dia = @restaurante.bloqueo_dia
    # TODO: margen_reserva se utiliza en el codigo PHP ?
    @margen_reserva = @restaurante.margen_reserva.hour.hour + @restaurante.margen_reserva.min.minutes
    @bloqueo_hora = (Time.zone.now + @margen_reserva).to_i

    # Aperturas en promo
    if !@promo.blank?
      @promobreak = @promo["break_"+@letraDia]
      @promoalmuerzo = @promo["almuerzo_"+@letraDia]
      @promoonces = @promo["onces_"+@letraDia]
      @promocena = @promo["cena_"+@letraDia]
    end

    # Calculos fecha
    if @modoreservas == 0
      # Datos horarios
      datosHorarios

      # Calculos apertura
      # TODO: tiempoapertura se utiliza en el codigo PHP ?
      # @tiempoapertura = getTiempoApertura

      # Ajusto los dias de apertura si hay promo seleccionada
      if !@promo.blank?
        @abierto_break = 0 if @promobreak == 0
        @abierto_almuerzo = 0 if @promoalmuerzo == 0
        @abierto_onces = 0 if @promoonces == 0
        @abierto_cena = 0 if @promocena == 0
      end

      # Arrays de parrilla
      arrayParrilla

      # Arrays de plazas
      @arrayplazas = Array.new
      # Mesas
      restaurantesMesas = RestaurantesMesa.find(:all,
        :select => "idmesa,plazas_min,plazas_max",
        :joins => "join restaurantes_salones on restaurantes_mesas.salon=restaurantes_salones.idsalon",
        :conditions => "restaurante='"+@restaurante.id.to_s+"' and visible='1' and mesafija='1'",
        :order => "restaurantes_mesas.nombre ASC"
        )

      restaurantesMesas.each do |restaurantesMesa|
        # Datos mesa
        @idmesa = restaurantesMesa.idmesa
        @plazas_min = restaurantesMesa.plazas_min
        @plazas_max = restaurantesMesa.plazas_max

        # Calculo disponibilidad de mesa por turno y bloque
        @bloquesbreak = 0
        @bloquesalmuerzo = 0
        @bloquesonces = 0
        @bloquescena = 0
        @maxbloquesbreak = 0
        @maxbloquesalmuerzo = 0
        @maxbloquesonces = 0
        @maxbloquescena = 0

        calculoBreak
        calculoAlmuerzo
        calculoOnce
        calculoCena

        # Extraccion de plazas disponibles
        getPlazasDisponiblesPersonas
      end

      # Combinaciones
      restaurantesCombinaciones = RestaurantesCombinacione.find(:all,
        :select => "idcombinacion,salon,combinacion,plazas_min,plazas_max",
        :joins => "join restaurantes_salones on restaurantes_combinaciones.salon=restaurantes_salones.idsalon",
        :conditions => "restaurante='"+@restaurante.id.to_s+"' and visible=1 and mesafija=1",
        :order => "restaurantes_combinaciones.combinacion ASC"
        )
      restaurantesCombinaciones.each do |restaurantesCombinacion|
        # Datos combinacion
        @idcombinacion = restaurantesCombinacion.idcombinacion
        @salon = restaurantesCombinacion.salon
        @combinacion = restaurantesCombinacion.combinacion
        @arraymesas = @combinacion.split(",")
        @plazas_min = restaurantesCombinacion.plazas_min
        @plazas_max = restaurantesCombinacion.plazas_max

        # Calculo disponibilidad de mesa por turno y bloque
        @bloquesbreak = 0
        @bloquesalmuerzo = 0
        @bloquesonces = 0
        @bloquescena = 0
        @maxbloquesbreak = 0
        @maxbloquesalmuerzo = 0
        @maxbloquesonces = 0
        @maxbloquescena = 0

        calculoBreakCombinacion
        calculoAlmuerzoCombinacion
        calculoOnceCombinacion
        calculoCenaCombinacion

        # Extraccion de plazas disponibles
        getPlazasDisponiblesPersonas
      end

      arrayplazasord = @arrayplazas.uniq

      @result = Array.new
      (@plazasmin..@plazasmax).each do |i|
        if !@promo.blank?
          @result << {i => (arrayplazasord.include?(i) && @arrayplazaspromo.include?(i))}
        else
          @result << {i => arrayplazasord.include?(i)}
        end
      end
    else
    # If modo reserva == 1
      # Datos horarios
      restaurantes_plazas = Restaurante.all(
                  select: "restaurantes.*,
                           restaurantes_plazas.break as plazasbreak,
                           restaurantes_plazas.almuerzo as plazasalmuerzo,
                           restaurantes_plazas.onces as plazasonces,
                           restaurantes_plazas.cena as plazascena,
                           (select sum(comensales) from restaurantes_reservas where restaurante='"+@restaurante.id.to_s+"' and promocion='"+@idPromocion+"' and fecha_reserva='"+@fecha.strftime('%F').to_s+"' and turno='break' and cancelado='0') as usosplazasbreak,
                           (select sum(comensales) from restaurantes_reservas where restaurante='"+@restaurante.id.to_s+"' and promocion='"+@idPromocion+"' and fecha_reserva='"+@fecha.strftime('%F').to_s+"' and turno='almuerzo' and cancelado='0') as usosplazasalmuerzo,
                           (select sum(comensales) from restaurantes_reservas where restaurante='"+@restaurante.id.to_s+"' and promocion='"+@idPromocion+"' and fecha_reserva='"+@fecha.strftime('%F').to_s+"' and turno='onces'  and cancelado='0') as usosplazasonces,
                           (select sum(comensales) from restaurantes_reservas where restaurante='"+@restaurante.id.to_s+"' and promocion='"+@idPromocion+"' and fecha_reserva='"+@fecha.strftime('%F').to_s+"' and turno='cena' and cancelado='0') as usosplazascena",
                  joins:  "LEFT JOIN restaurantes_plazas ON restaurantes.idrestaurante = restaurantes_plazas.restaurante",
                  conditions:  "idrestaurante='"+@restaurante.id.to_s+"' and restaurantes_plazas.fecha='"+@fecha.strftime('%F').to_s+"'").first

      @abierto_break = restaurantes_plazas['break_'+@letraDia]
      @abierto_almuerzo = restaurantes_plazas['almuerzo_'+@letraDia]
      @abierto_onces = restaurantes_plazas['onces_'+@letraDia]
      @abierto_cena = restaurantes_plazas['cena_'+@letraDia]
      plazasbreak = restaurantes_plazas['plazasbreak']
      plazasalmuerzo = restaurantes_plazas['plazasalmuerzo']
      plazasonces = restaurantes_plazas['plazasonces']
      plazascena = restaurantes_plazas['plazascena']
      usosplazasbreak = restaurantes_plazas['usosplazasbreak']
      usosplazasalmuerzo = restaurantes_plazas['usosplazasalmuerzo']
      usosplazasonces = restaurantes_plazas['usosplazasonces']
      usosplazascena = restaurantes_plazas['usosplazascena']

      plazasbreak = 0 if @abierto_break == 0
      plazasalmuerzo = 0 if @abierto_almuerzo == 0
      plazasonces = 0 if @abierto_onces == 0
      plazascena = 0 if @abierto_cena == 0
      usosplazasbreak = 0 if !usosplazasbreak
      usosplazasalmuerzo = 0 if !usosplazasalmuerzo
      usosplazasonces = 0 if !usosplazasonces
      usosplazascena = 0 if !usosplazascena

      plazaslibresbreak = plazasbreak - usosplazasbreak
      plazaslibresalmuerzo = plazasalmuerzo - usosplazasalmuerzo
      plazaslibresonces = plazasonces - usosplazasonces
      plazaslibrescena = plazascena - usosplazascena

      # Ajusto los dias de apertura si hay promo seleccionada
      if !@idPromocion.blank?
        @abierto_break = 0 if @promobreak == 0
        @abierto_almuerzo = 0 if @promoalmuerzo == 0
        @abierto_onces = 0 if @promoonces == 0
        @abierto_cena = 0 if @promocena == 0
      end

      # Calculo las plazas dependiendo de todos los parámetros
      @plazasmax = [plazasbreak,plazasalmuerzo,plazasonces,plazascena].max
      plazaslibresmax = [plazaslibresbreak,plazaslibresalmuerzo,plazaslibresonces,plazaslibrescena].max

      @result = Array.new
      (1..@plazasmax).each do |i|
        if i <= plazaslibresmax
          @result << {i => true}
        elsif @restaurante.listaespera
          @result << {i => "listaEspera"}
        else
          @result << {i => false}
        end
      end
    end
    respond_to do |format|
      format.json { render json: @result }
      format.xml { render '/app/views/api_mesafijas/rest_disponibilidad_rango_plazas.xml.builder' }
    end
  end

  # Servicio que suministra la disponibilidad del restaurante. Si suministramos además el número de comensales, nos devolverá los
  # horarios disponibles para la fecha y número de comensales seleccionados
  # ?idRestaurante=126&fecha=2014-03-09&comensales=1
  def rest_disponibilidad_turno_disponibles
    @restaurante = Restaurante.where(:idrestaurante => params[:idRestaurante]).first
    showError("No existe el restaurante") and return if @restaurante.nil?

    showError("Falta la fecha. El formato de la fecha es “AAAA-MM-DD” ie: 2014-01-16") and return if params[:fecha].blank?
    @fecha = Time.zone.parse(params[:fecha])
    @fecha = Time.zone.now if @fecha.blank?
    @letraDia = getLetraDia(@fecha)

    showError("Falta numero de comensales. Debe de ser un entero") and return if params[:comensales].blank?
    @personas = params[:comensales].to_i

    turno = 0

    @promo = RestaurantesPromo.where(:idpromo => params[:idPromocion]).first unless params[:idPromocion].blank?
    (@promo.blank?) ? @idPromocion = "0" : @idPromocion = @promo.id.to_s

    @modoreservas = @restaurante.modoreservas

    # Aperturas en promo
    # aperturaPromo

    # Minimo plazas restaurante
    @plazasmin = getMinimoPlazasRestaurante

    # Maximo plazas restaurante
    @plazasmax = getMaximoPlazasRestaurante

    # Tiempos x mesa
    tiempoPorMesaTurno

    @bloqueo_dia = @restaurante.bloqueo_dia
    @margen_reserva = Time.zone.now.end_of_day + 1.second - @restaurante.margen_reserva.hour.hour - @restaurante.margen_reserva.min.minutes
    @bloqueo_hora = Time.zone.now + @restaurante.margen_reserva.hour.hour + @restaurante.margen_reserva.min.minutes

    # Aperturas en promo
    if !@promo.blank?
      @promobreak = @promo["break_"+@letraDia]
      @promoalmuerzo = @promo["almuerzo_"+@letraDia]
      @promoonces = @promo["onces_"+@letraDia]
      @promocena = @promo["cena_"+@letraDia]
    end

    # Calculos fecha
    if @modoreservas == 0
      # Datos horarios
      datosHorarios

      # Ajusto los dias de apertura si hay promo seleccionada
      if !@promo.blank?
        @abierto_break = 0 if @promobreak == 0
        @abierto_almuerzo = 0 if @promoalmuerzo == 0
        @abierto_onces = 0 if @promoonces == 0
        @abierto_cena = 0 if @promocena == 0
      end

      # Calculos apertura
      # @tiempoapertura = getTiempoApertura

      # Arrays de parrilla
      arrayParrilla

      # Arrays de plazas
      @arrayplazas = Array.new
      # Mesas
      restaurantesMesas = RestaurantesMesa.find(:all,
        :select => "idmesa,plazas_min,plazas_max",
        :joins => "join restaurantes_salones on restaurantes_mesas.salon=restaurantes_salones.idsalon",
        :conditions => "restaurante='"+@restaurante.id.to_s+"' and visible='1' and plazas_min <= '"+@personas.to_s+"' and plazas_max >= '"+@personas.to_s+"' and mesafija='1' ",
        :order => "restaurantes_mesas.nombre ASC"
        )
      restaurantesMesas.each do |restaurantesMesa|
        # Datos mesa
        @idmesa = restaurantesMesa.idmesa

        # Calculo disponibilidad de mesa por turno y bloque
        @bloquesbreak = 0
        @bloquesalmuerzo = 0
        @bloquesonces = 0
        @bloquescena = 0
        @maxbloquesbreak = 0
        @maxbloquesalmuerzo = 0
        @maxbloquesonces = 0
        @maxbloquescena = 0

        calculoBreak
        calculoAlmuerzo
        calculoOnce
        calculoCena

        getPlazasDisponiblesTurno
      end

      # Combinaciones
      restaurantesCombinaciones = RestaurantesCombinacione.find(:all,
        :select => "idcombinacion,salon,combinacion,plazas_min,plazas_max",
        :joins => "join restaurantes_salones on restaurantes_combinaciones.salon=restaurantes_salones.idsalon",
        :conditions => "restaurante='"+@restaurante.id.to_s+"' and visible='1' and plazas_min <= '"+@personas.to_s+"' and plazas_max >= '"+@personas.to_s+"' and mesafija='1' ",
        :order => "restaurantes_combinaciones.combinacion ASC"
        )
      restaurantesCombinaciones.each do |restaurantesCombinacion|
        # Datos combinacion
        @idcombinacion = restaurantesCombinacion.idcombinacion
        @salon = restaurantesCombinacion.salon
        @combinacion = restaurantesCombinacion.combinacion
        @arraymesas = @combinacion.split(",")

        # Calculo disponibilidad de mesa por turno y bloque
        @bloquesbreak = 0
        @bloquesalmuerzo = 0
        @bloquesonces = 0
        @bloquescena = 0
        @maxbloquesbreak = 0
        @maxbloquesalmuerzo = 0
        @maxbloquesonces = 0
        @maxbloquescena = 0

        calculoBreakCombinacion
        calculoAlmuerzoCombinacion
        calculoOnceCombinacion
        calculoCenaCombinacion

        # Extraccion de plazas disponibles
        if @bloques_nec <= @maxbloquesbreak then @combbreak = 1 end
        if @bloques_nec <= @maxbloquesalmuerzo then @combalmuerzo = 1 end
        if @bloques_nec <= @maxbloquesonces then @combonces = 1 end
        if @bloques_nec <= @maxbloquescena then @combcena = 1 end
      end

      @result = Array.new
      @result << {"Break a.m." => (@mesasbreak==1 || @combbreak==1)}
      @result << {"Almuerzo" => (@mesasalmuerzo==1 || @combalmuerzo==1)}
      @result << {"Break p.m." => (@mesasonces==1 || @combonces==1)}
      @result << {"Cena" => (@mesascena==1 || @combcena==1)}
    else
    # Modo reserva == 1
      @abierto_break = @restaurante['break_'+@letraDia]
      @abierto_almuerzo = @restaurante['almuerzo_'+@letraDia]
      @abierto_onces = @restaurante['onces_'+@letraDia]
      @abierto_cena = @restaurante['cena_'+@letraDia]

      # Ajusto los dias de apertura si hay promo seleccionada
      if !@promo.blank?
        @abierto_break = 0 if @promobreak == 0
        @abierto_almuerzo = 0 if @promoalmuerzo == 0
        @abierto_onces = 0 if @promoonces == 0
        @abierto_cena = 0 if @promocena == 0
      end

      restaurantes_plazas = Restaurante.all(
                  select: "restaurantes.*,
                           restaurantes_plazas.break as plazasbreak,
                           restaurantes_plazas.almuerzo as plazasalmuerzo,
                           restaurantes_plazas.onces as plazasonces,
                           restaurantes_plazas.cena as plazascena,
                           (select sum(comensales) from restaurantes_reservas where restaurante="+@restaurante.id.to_s+" and promocion='"+@idPromocion+"' and fecha_reserva='"+@fecha.strftime('%F').to_s+"' and turno='break' and cancelado='0') as usosplazasbreak,
                           (select sum(comensales) from restaurantes_reservas where restaurante="+@restaurante.id.to_s+" and promocion='"+@idPromocion+"' and fecha_reserva='"+@fecha.strftime('%F').to_s+"' and turno='almuerzo' and cancelado='0') as usosplazasalmuerzo,
                           (select sum(comensales) from restaurantes_reservas where restaurante="+@restaurante.id.to_s+" and promocion='"+@idPromocion+"' and fecha_reserva='"+@fecha.strftime('%F').to_s+"' and turno='onces'  and cancelado='0') as usosplazasonces,
                           (select sum(comensales) from restaurantes_reservas where restaurante="+@restaurante.id.to_s+" and promocion='"+@idPromocion+"' and fecha_reserva='"+@fecha.strftime('%F').to_s+"' and turno='cena' and cancelado='0') as usosplazascena",
                  joins:  "LEFT JOIN restaurantes_plazas ON restaurantes.idrestaurante = restaurantes_plazas.restaurante",
                  conditions:  "restaurantes.idrestaurante='"+@restaurante.id.to_s+"' and restaurantes_plazas.fecha='"+@fecha.strftime('%F').to_s+"'").first

      @abierto_break = restaurantes_plazas['break_'+@letraDia]
      @abierto_almuerzo = restaurantes_plazas['almuerzo_'+@letraDia]
      @abierto_onces = restaurantes_plazas['onces_'+@letraDia]
      @abierto_cena = restaurantes_plazas['cena_'+@letraDia]
      plazasbreak = restaurantes_plazas['plazasbreak'].to_i
      plazasalmuerzo = restaurantes_plazas['plazasalmuerzo'].to_i
      plazasonces = restaurantes_plazas['plazasonces'].to_i
      plazascena = restaurantes_plazas['plazascena'].to_i
      usosplazasbreak = restaurantes_plazas['usosplazasbreak'].to_i
      usosplazasalmuerzo = restaurantes_plazas['usosplazasalmuerzo'].to_i
      usosplazasonces = restaurantes_plazas['usosplazasonces'].to_i
      usosplazascena = restaurantes_plazas['usosplazascena'].to_i
      # byebug


      @result = Array.new
      if @abierto_break == 1 && @personas <= plazasbreak - usosplazasbreak
        @result << {"Break a.m." => true}
      elsif @abierto_break == 1 && @restaurante.listaespera == 1 && @personas <= plazasbreak && @personas > (plazasbreak-usosplazasbreak)
        @result << {"Break a.m." => "listaEspera"}
      else
        @result << {"Break a.m." => false}
      end

      if @abierto_almuerzo == 1 && @personas <= plazasalmuerzo - usosplazasalmuerzo
        @result << {"Almuerzo" => true}
      elsif @abierto_almuerzo == 1 && @restaurante.listaespera == 1 && @personas <= plazasalmuerzo && @personas > (plazasalmuerzo-usosplazasalmuerzo)
        @result << {"Almuerzo" => "listaEspera"}
      else
        @result << {"Almuerzo" => false}
      end

      if @abierto_onces == 1 && @personas <= plazasonces - usosplazasonces
        @result << {"Break p.m." => true}
      elsif @abierto_onces == 1 && @restaurante.listaespera == 1 && @personas <= plazasonces && @personas > (plazasonces-usosplazasonces)
        @result << {"Break p.m." => "listaEspera"}
      else
        @result << {"Break p.m." => false}
      end

      if @abierto_cena == 1 && @personas <= plazascena - usosplazascena
        @result << {"Cena" => true}
      elsif @abierto_cena == 1 && @restaurante.listaespera == 1 && @personas <= plazascena && @personas > (plazascena-usosplazascena)
        @result << {"Cena" => "listaEspera"}
      else
        @result << {"Cena" => false}
      end
    end
    respond_to do |format|
      format.json { render json: @result }
      format.xml { render '/app/views/api_mesafijas/rest_disponibilidad_turno_disponibles.xml.builder' }
    end
  end

  # idRestaurante=126&fecha=2014-03-09&comensales=1&turno=4
  def rest_disponibilidad_horas_disponibles
    @restaurante = Restaurante.where(:idrestaurante => params[:idRestaurante]).first
    respond_with(nil) and return if @restaurante.nil?

    @fecha = Time.zone.parse(params[:fecha]) unless params[:fecha].blank?
    @fecha = Time.zone.now if @fecha.blank?
    @letraDia = getLetraDia(@fecha)

    @personas = params[:comensales].to_i
    @personas = 2 if params[:comensales].blank?

    @turno = params[:turno].to_i
    @turno = 1 if params[:turno].blank?

    @promo = RestaurantesPromo.where(:idpromo => params[:idPromocion]).first unless params[:idPromocion].blank?
    (@promo.blank?) ? @idPromocion = "0" : @idPromocion = @promo.id.to_s

    @modoreservas = @restaurante.modoreservas

    # Aperturas en promo
    aperturaPromo

    # Minimo plazas restaurante
    @plazasmin = getMinimoPlazasRestaurante

    # Maximo plazas restaurante
    @plazasmax = getMaximoPlazasRestaurante

    # Tiempos x mesa
    tiempoPorMesaTurno

    @bloqueo_dia = @restaurante.bloqueo_dia
    @margen_reserva = Time.zone.now.end_of_day + 1.second - @restaurante.margen_reserva.hour.hour - @restaurante.margen_reserva.min.minutes
    @bloqueo_hora = Time.zone.now + @restaurante.margen_reserva.hour.hour + @restaurante.margen_reserva.min.minutes

    datosHorarios

    if @turno == 1
      @abierto = @abierto_break
      @horario = @horario_break
      @apertura = @apertura_break
      @cierre = @cierre_break
      @txtturno = 'break'
    elsif @turno == 2
      @abierto = @abierto_almuerzo
      @horario = @horario_almuerzo
      @apertura = @apertura_almuerzo
      @cierre = @cierre_almuerzo
      @txtturno = 'almuerzo'
    elsif @turno == 3
      @abierto = @abierto_onces
      @horario = @horario_onces
      @apertura = @apertura_onces
      @cierre = @cierre_onces
      @txtturno = 'onces'
    elsif @turno == 4
      @abierto = @abierto_cena
      @horario = @horario_cena
      @apertura = @apertura_cena
      @cierre = @cierre_cena
      @txtturno = 'cena'
    end

    # Calculos apertura
    # @tiempoapertura = getTiempoApertura

    @result = Array.new
    if @modoreservas == 0
      if @abierto == 1 && @horario >= @tiempo_minimo
        horaparrilla = @apertura


        while horaparrilla <= @cierre-(@bloques_nec*1800) do
          @arrayhora = horaparrilla
          @hora_nec = horaparrilla + (@bloques_nec*1800)
          @contadormesas = 0
          @contadorcomb = 0
          # Mesas
          restaurantesMesas = RestaurantesMesa.find(:all,
            :select => "idmesa,plazas_min,plazas_max",
            :joins => "join restaurantes_salones on restaurantes_mesas.salon=restaurantes_salones.idsalon",
            :conditions => "restaurante='"+@restaurante.id.to_s+"' and visible='1' and plazas_min <= '"+@personas.to_s+"' and plazas_max >= '"+@personas.to_s+"' and mesafija='1' ",
            :order => "restaurantes_mesas.nombre ASC"
            )
          restaurantesMesas.each do |restaurantesMesa|
            # Datos mesa
            @idmesa = restaurantesMesa.idmesa

            # Calculo disponibilidad de mesa por turno y bloque
            @bloquesbreak = 0
            @bloquesalmuerzo = 0
            @bloquesonces = 0
            @bloquescena = 0
            @maxbloquesbreak = 0
            @maxbloquesalmuerzo = 0
            @maxbloquesonces = 0
            @maxbloquescena = 0

            # Revisamos si hay alguna reserva
            restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("mesa = ? and cancelado = ? and fecha_reserva = ? and hora_reserva <= ? and addtime(hora_reserva,tiempo) > ? and turno = ?", @idmesa, 0, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @arrayhora.strftime("%T"), @txtturno)
            numreservasmesa = restaurantesReservas.count

            # Revisamos si en el tiempo necesario para realizar esta reserva hay otra reserva
            restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("mesa = ? and cancelado = ? and fecha_reserva = ? and hora_reserva > ? and hora_reserva < ? and turno = ?", @idmesa, 0, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @hora_nec.strftime("%T"), @txtturno)
            numreservasfuturasmesa = restaurantesReservas.count

            # Revisamos si en una combinación con esta mesa hay alguna reserva
            restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>? and turno = ?", @idmesa, 0, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @arrayhora.strftime("%T"), @txtturno)
            numreservascomb = restaurantesReservas.count

            # Revisamos si en el tiempo necesario para realizar esta reserva hay alguna reserva en una combinación con esta mesa
            restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva > ? and hora_reserva < ? and turno = ?", @idmesa, 0, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @hora_nec.strftime("%T"), @txtturno)
            numreservasfuturascomb = restaurantesReservas.count

            # Revisamos si en esta mesa hay algun bloqueo
            restaurantesBloqueos = RestaurantesBloqueo.select("hora").where(:mesa => @idmesa, :fecha => @fecha.strftime("%F"), :hora => @arrayhora.strftime("%T"))
            numbloqueosmesa = restaurantesBloqueos.count

            # Revisamos si en el tiempo necesario para realizar esta reserva hay algun bloqueo
            restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("mesa = ? and fecha = ? and hora > ? and hora < ?", @idmesa, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @hora_nec.strftime("%T"))
            numbloqueosfuturosmesa = restaurantesBloqueos.count

            # Revisamos si en una combinación con esta mesa hay algun bloqueo
            restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and fecha=? and hora=?", @idmesa, @fecha.strftime("%F"), @arrayhora.strftime("%T"))
            numbloqueoscomb = restaurantesBloqueos.count

            #Revisamos si en el tiempo necesario para realizar esta reserva en una combinación con esta mesa hay algun bloqueo
            restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and fecha=? and hora > ? and hora < ?", @idmesa, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @hora_nec.strftime("%T"))
            numbloqueosfuturoscomb = restaurantesBloqueos.count

            # Comprobamos resultados
            if numreservasmesa == 0 && numreservasfuturasmesa == 0 && numreservascomb == 0 && numreservasfuturascomb == 0 && numbloqueosmesa == 0 && numbloqueosfuturosmesa == 0 && numbloqueoscomb == 0 && numbloqueosfuturoscomb == 0
              @contadormesas += 1
            end
          end

          # Combinaciones
          restaurantesCombinaciones = RestaurantesCombinacione.find(:all,
            :select => "idcombinacion,salon,combinacion,plazas_min,plazas_max",
            :joins => "join restaurantes_salones on restaurantes_combinaciones.salon=restaurantes_salones.idsalon",
            :conditions => "restaurante='"+@restaurante.id.to_s+"' and visible='1' and plazas_min <= '"+@personas.to_s+"' and plazas_max >= '"+@personas.to_s+"' and mesafija='1' ",
            :order => "restaurantes_combinaciones.combinacion ASC"
            )
          restaurantesCombinaciones.each do |restaurantesCombinacion|
            # Datos combinacion
            @idcombinacion = restaurantesCombinacion.idcombinacion
            @salon = restaurantesCombinacion.salon
            @combinacion = restaurantesCombinacion.combinacion
            @arraymesas = @combinacion.split(",")

            # Calculo disponibilidad de mesa por turno y bloque
            @bloquesbreak = 0
            @bloquesalmuerzo = 0
            @bloquesonces = 0
            @bloquescena = 0
            @maxbloquesbreak = 0
            @maxbloquesalmuerzo = 0
            @maxbloquesonces = 0
            @maxbloquescena = 0

            # Revisamos si en esta combinacion hay alguna reserva
            numreservascomb = RestaurantesReserva.getNumreservascomb(@idcombinacion, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @txtturno).count

            # Revisamos si en el tiempo necesario para realizar esta reserva hay alguna reserva en esta combinacion
            numreservasfuturascomb = RestaurantesReserva.getNumreservasfuturascomb(@idcombinacion, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @hora_nec.strftime("%T"), @txtturno).count

            # Revisamos si alguna mesa de esta combinación tiene alguna reserva
            numreservasmesacomb = RestaurantesReserva.getNumreservasmesacomb(@combinacion, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @txtturno).count

            # Revisamos si en el tiempo necesario para realizar esta reserva en alguna mesa de esta combinación hay alguna reserva
            numreservasfuturasmesacomb = RestaurantesReserva.getNumreservasfuturasmesacomb(@combinacion, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @hora_nec.strftime("%T"), @txtturno).count

            # Revisamos si alguna mesa de esta combinación está en otra combinacion que tiene alguna reserva
            numreservasmesaotracomb = 0
            @arraymesas.each do |mesa|
              restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>? and turno=?", @salon, mesa, 0, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @arrayhora.strftime("%T"), @txtturno)
              numreservasmesaotracomb += restaurantesReservas.count
            end

            # Revisamos si en el tiempo necesario para realizar esta reserva alguna mesa de esta combinación está en otra combinacion que tiene alguna reserva
            numreservasfuturasmesaotracomb = 0
            @arraymesas.each do |mesa|
              restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva>? and hora_reserva<? and turno=?", @salon, mesa, 0, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @hora_nec.strftime("%T"), @txtturno)
              numreservasfuturasmesaotracomb += restaurantesReservas.count
            end

            # Revisamos si en esta combinacion hay algun bloqueo
            numbloqueoscomb = RestaurantesBloqueo.getNumbloqueoscomb(@idcombinacion, @fecha.strftime("%F"), @arrayhora.strftime("%T")).count

            # Revisamos si en el tiempo necesario para realizar esta reserva en esta combinacion hay algun bloqueo
            numbloqueosfuturoscomb = RestaurantesBloqueo.getNumbloqueosfuturoscomb(@idcombinacion, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @hora_nec.strftime("%T") ).count

            # Revisamos si alguna mesa de esta combinación tiene algun bloqueo
            numbloqueosmesacomb = RestaurantesBloqueo.getNumbloqueosmesacomb(@combinacion, @fecha.strftime("%F"), @arrayhora.strftime("%T")).count

            # Revisamos si en el tiempo necesario para realizar esta reserva alguna mesa de esta combinación tiene algun bloqueo
            numbloqueosfuturosmesacomb = RestaurantesBloqueo.getNumbloqueosfuturosmesacomb(@combinacion, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @hora_nec.strftime("%T") ).count

            # Revisamos si alguna mesa de esta combinación está en otra combinacion que tiene algun bloqueo
            numbloqueosmesaotracomb = 0
            @arraymesas.each do |mesa|
              restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and fecha=? and hora=?", @salon, mesa, @fecha.strftime("%F"), @arrayhora.strftime("%T"))
              numbloqueosmesaotracomb += restaurantesBloqueos.count
            end

            # Revisamos si en el tiempo necesario para realizar esta reserva alguna mesa de esta combinación está en otra combinacion que tiene algun bloqueo
            numbloqueosfuturosmesaotracomb = 0
            @arraymesas.each do |mesa|
              restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and fecha=? and hora > ? and hora < ?", @salon, mesa, @fecha.strftime("%F"), @arrayhora.strftime("%T"), @hora_nec.strftime("%T"))
              numbloqueosfuturosmesaotracomb += restaurantesBloqueos.count
            end

            # comprobamos resultados -->
            if numreservascomb == 0 && numreservasfuturascomb == 0 && numreservasmesacomb == 0 && numreservasfuturasmesacomb == 0 && numreservasmesaotracomb == 0 && numreservasfuturasmesaotracomb == 0 && numbloqueoscomb == 0 && numbloqueosfuturoscomb == 0 && numbloqueosmesacomb == 0 && numbloqueosfuturosmesacomb == 0 && numbloqueosmesaotracomb == 0 && numbloqueosfuturosmesaotracomb == 0
              @contadorcomb += 1
            end
          end

          if @fecha == Time.zone.today && horaparrilla.to_i < @bloqueo_hora
            @result << {horaparrilla.strftime("%R") => false}
          elsif @contadormesas > 0 || @contadorcomb > 0
            @result << {horaparrilla.strftime("%R") => true}
          else
            @result << {horaparrilla.strftime("%R") => false}
          end

          horaparrilla += 1800
        end

        horaparrilla = @cierre - ((@bloques_nec-1)*1800)
        while horaparrilla < @cierre do
          @result << {horaparrilla.strftime("%R") => false}
          horaparrilla += 1800
        end
      end
    else
    # Modo reserva = 1
      restaurantes_plazas = RestaurantesPlaza.all(
                  select:  @txtturno+" as plazas,
                           (select sum(comensales) from restaurantes_reservas where restaurante="+@restaurante.id.to_s+" and promocion='"+@idPromocion+"' and fecha_reserva='"+@fecha.strftime('%F').to_s+"' and turno='"+@txtturno+"' and cancelado='0') as usos",
                  conditions:  "restaurante='"+@restaurante.id.to_s+"' and fecha='"+@fecha.strftime('%F').to_s+"'").first
      plazas = restaurantes_plazas.plazas.to_i
      usos = restaurantes_plazas.usos.to_i

      if @abierto == 1 && @horario >= @tiempo_minimo
        horaparrilla = @apertura
        while horaparrilla < @cierre do
          if @fecha == Time.zone.today && horaparrilla.to_i < @bloqueo_hora
            @result << {horaparrilla.strftime("%R") => false}
          elsif @personas <= (plazas - usos)
            @result << {horaparrilla.strftime("%R") => true}
          elsif @personas > (plazas - usos)
            @result << {horaparrilla.strftime("%R") => "listaEspera"}
          end
          horaparrilla += 1800
        end
      end
    end
    respond_to do |format|
      format.json { render json: @result }
      format.xml { render '/app/views/api_mesafijas/rest_disponibilidad_horas_disponibles.xml.builder' }
    end
  end

  # Servicio que permite reservar mediante los datos proporcionados con los servicios rest-
  # disponibilidad.php y usuario-datos.php
  # Mirar el code-reserva-guardar.php
  def rest_reserva_agregar
    @restaurante = Restaurante.where(:idrestaurante => params[:idRestaurante]).first
    respond_with(nil) and return if @restaurante.nil?

    @fecha = Time.zone.parse(params[:fecha]) unless params[:fecha].blank?
    @fecha = Time.zone.now if @fecha.blank?
    @letraDia = getLetraDia(@fecha)

    @personas = params[:comensales].to_i
    respond_with("Comensales vacio") and return if @personas.nil?

    @turno = params[:turno].to_i
    respond_with("Turno vacio") and return if @turno.nil?

    @hora = params[:hora].to_datetime
    respond_with("Hora vacia") and return if @hora.nil?

    @user = RestaurantesUsuario.where(:id_usuario => params[:idUsuario]).first
    respond_with("Usuario vacio") and return if @user.nil?

    @promo = RestaurantesPromo.where(:idpromo => params[:idPromocion]).first unless params[:idPromocion].blank?
    (@promo.blank?) ? @idPromocion = "0" : @idPromocion = @promo.id.to_s

    @modoreservas = @restaurante.modoreservas

    @observaciones = params[:observaciones].to_s

    if @modoreservas == 0
      if @turno == 1
        @txtturno = 'break'
      elsif @turno == 2
        @txtturno = 'almuerzo'
      elsif @turno == 3
        @txtturno = 'onces'
      elsif @turno == 4
        @txtturno = 'cena'
      end

      # TODO : Mirar si en los demas sitios que pone ".day - 1).day" estan bien. Sino, hacerlo como esto.
      @horaabs = @fecha.change({:hour => @hora.hour, :min => @hora.min })
      @horaabs = @horaabs + 1.day unless @hora.today?
      if @personas > 10
        restaurantesTiempos = RestaurantesTiempo.select("tiempo_grupos as tiempo").where(:restaurante => @restaurante.id).first
      else
        restaurantesTiempos = RestaurantesTiempo.select("tiempo_#{@personas.to_s} as tiempo").where(:restaurante => @restaurante.id).first
      end
      @tiempo = restaurantesTiempos.tiempo
      @tiempoabs = @tiempo.hour.hour + @tiempo.min.minutes
      @bloques_nec = @tiempoabs/3600*2
      @hora_nec = @horaabs + (@bloques_nec*1800)
      @mesa = 0
      @combinacion = 0

      # Mesas con capacidad minima
      restaurantesMesas = RestaurantesMesa.find(:all,
        :select => "idmesa",
        :joins => "join restaurantes_salones on restaurantes_mesas.salon=restaurantes_salones.idsalon",
        :conditions => "restaurante='"+@restaurante.id.to_s+"' and visible='1' and plazas_min <= '"+@personas.to_s+"' and plazas_max >= '"+@personas.to_s+"' and mesafija='1' ",
        :order => "restaurantes_mesas.plazas ASC"
        )
      restaurantesMesas.each do |restaurantesMesa|
        @idmesa = restaurantesMesa.idmesa

        # Revisamos si hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("mesa = ? and cancelado = ? and fecha_reserva = ? and hora_reserva <= ? and addtime(hora_reserva,tiempo) > ?", @idmesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora.strftime("%T"))
        numreservasmesa = restaurantesReservas.count

        # Revisamos si en el tiempo necesario para realizar esta reserva hay otra reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("mesa = ? and cancelado = ? and fecha_reserva = ? and hora_reserva > ? and hora_reserva < ?", @idmesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
        numreservasfuturasmesa = restaurantesReservas.count

        # Revisamos si en una combinación con esta mesa hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @idmesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora.strftime("%T"))
        numreservascomb = restaurantesReservas.count

        # Revisamos si en el tiempo necesario para realizar esta reserva hay alguna reserva en una combinación con esta mesa
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva > ? and hora_reserva < ?", @idmesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
        numreservasfuturascomb = restaurantesReservas.count

        # Revisamos si en esta mesa hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where(:mesa => @idmesa, :fecha => @fecha.strftime("%F"), :hora => @hora.strftime("%T"))
        numbloqueosmesa = restaurantesBloqueos.count

        # Revisamos si en el tiempo necesario para realizar esta reserva hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("mesa = ? and fecha = ? and hora > ? and hora < ?", @idmesa, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
        numbloqueosfuturosmesa = restaurantesBloqueos.count

        # Revisamos si en una combinación con esta mesa hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and fecha=? and hora=?", @idmesa, @fecha.strftime("%F"), @hora.strftime("%T"))
        numbloqueoscomb = restaurantesBloqueos.count

        #Revisamos si en el tiempo necesario para realizar esta reserva en una combinación con esta mesa hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and fecha=? and hora > ? and hora < ?", @idmesa, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
        numbloqueosfuturoscomb = restaurantesBloqueos.count

        # Comprobamos resultados
        if numreservasmesa == 0 && numreservasfuturasmesa == 0 && numreservascomb == 0 && numreservasfuturascomb == 0 && numbloqueosmesa == 0 && numbloqueosfuturosmesa == 0 && numbloqueoscomb == 0 && numbloqueosfuturoscomb == 0
          @mesa = @idmesa
          break
        end
      end

      # Mesas con capacidad exacta
      restaurantesMesas = RestaurantesMesa.find(:all,
        :select => "idmesa",
        :joins => "join restaurantes_salones on restaurantes_mesas.salon=restaurantes_salones.idsalon",
        :conditions => "restaurante='"+@restaurante.id.to_s+"' and visible='1' and plazas = '"+@personas.to_s+"' and mesafija='1' ",
        :order => "restaurantes_mesas.nombre ASC"
        )
      restaurantesMesas.each do |restaurantesMesa|
        @idmesa = restaurantesMesa.idmesa

        # Revisamos si hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("mesa = ? and cancelado = ? and fecha_reserva = ? and hora_reserva <= ? and addtime(hora_reserva,tiempo) > ?", @idmesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora.strftime("%T"))
        numreservasmesa = restaurantesReservas.count

        # Revisamos si en el tiempo necesario para realizar esta reserva hay otra reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("mesa = ? and cancelado = ? and fecha_reserva = ? and hora_reserva > ? and hora_reserva < ?", @idmesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
        numreservasfuturasmesa = restaurantesReservas.count

        # Revisamos si en una combinación con esta mesa hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @idmesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora.strftime("%T"))
        numreservascomb = restaurantesReservas.count

        # Revisamos si en el tiempo necesario para realizar esta reserva hay alguna reserva en una combinación con esta mesa
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva > ? and hora_reserva < ?", @idmesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
        numreservasfuturascomb = restaurantesReservas.count

        # Revisamos si en esta mesa hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where(:mesa => @idmesa, :fecha => @fecha.strftime("%F"), :hora => @hora.strftime("%T"))
        numbloqueosmesa = restaurantesBloqueos.count

        # Revisamos si en el tiempo necesario para realizar esta reserva hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("mesa = ? and fecha = ? and hora > ? and hora < ?", @idmesa, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
        numbloqueosfuturosmesa = restaurantesBloqueos.count

        # Revisamos si en una combinación con esta mesa hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and fecha=? and hora=?", @idmesa, @fecha.strftime("%F"), @hora.strftime("%T"))
        numbloqueoscomb = restaurantesBloqueos.count

        #Revisamos si en el tiempo necesario para realizar esta reserva en una combinación con esta mesa hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and fecha=? and hora > ? and hora < ?", @idmesa, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
        numbloqueosfuturoscomb = restaurantesBloqueos.count

        # Comprobamos resultados
        if numreservasmesa == 0 && numreservasfuturasmesa == 0 && numreservascomb == 0 && numreservasfuturascomb == 0 && numbloqueosmesa == 0 && numbloqueosfuturosmesa == 0 && numbloqueoscomb == 0 && numbloqueosfuturoscomb == 0
          @mesa = @idmesa
          break
        end
      end

      # Combinaciones con capacidad minima
      restaurantesCombinaciones = RestaurantesCombinacione.find(:all,
        :select => "idcombinacion,salon,combinacion",
        :joins => "join restaurantes_salones on restaurantes_combinaciones.salon=restaurantes_salones.idsalon",
        :conditions => "restaurante='"+@restaurante.id.to_s+"' and visible='1' and plazas_min <= '"+@personas.to_s+"' and plazas_max >= '"+@personas.to_s+"' and mesafija='1' ",
        :order => "restaurantes_combinaciones.combinacion ASC"
        )
      restaurantesCombinaciones.each do |restaurantesCombinacion|
        # Datos combinacion
        @idcombinacion = restaurantesCombinacion.idcombinacion
        @salon = restaurantesCombinacion.salon
        @combinacion = restaurantesCombinacion.combinacion
        @arraymesas = @combinacion.split(",")

        # Revisamos si en esta combinacion hay alguna reserva
        numreservascomb = RestaurantesReserva.getNumreservascomb(@idcombinacion, @fecha, @hora.strftime("%T")).count

        # Revisamos si en el tiempo necesario para realizar esta reserva hay alguna reserva en esta combinacion
        numreservasfuturascomb = RestaurantesReserva.getNumreservasfuturascomb(@idcombinacion, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T")).count

        # Revisamos si alguna mesa de esta combinación tiene alguna reserva
        numreservasmesacomb = RestaurantesReserva.getNumreservasmesacomb(@combinacion, @fecha.strftime("%F"), @hora.strftime("%T")).count

        # Revisamos si en el tiempo necesario para realizar esta reserva en alguna mesa de esta combinación hay alguna reserva
        numreservasfuturasmesacomb = RestaurantesReserva.getNumreservasfuturasmesacomb(@combinacion, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T")).count

        # Revisamos si alguna mesa de esta combinación está en otra combinacion que tiene alguna reserva
        numreservasmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @salon, mesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora.strftime("%T"))
          numreservasmesaotracomb += restaurantesReservas.count
        end

        # Revisamos si en el tiempo necesario para realizar esta reserva alguna mesa de esta combinación está en otra combinacion que tiene alguna reserva
        numreservasfuturasmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva>? and hora_reserva<?", @salon, mesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
          numreservasfuturasmesaotracomb += restaurantesReservas.count
        end

        # Revisamos si en esta combinacion hay algun bloqueo
        numbloqueoscomb = RestaurantesBloqueo.getNumbloqueoscomb(@idcombinacion, @fecha.strftime("%F"), @hora.strftime("%T")).count

        # Revisamos si en el tiempo necesario para realizar esta reserva en esta combinacion hay algun bloqueo
        numbloqueosfuturoscomb = RestaurantesBloqueo.getNumbloqueosfuturoscomb(@idcombinacion, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T") ).count

        # Revisamos si alguna mesa de esta combinación tiene algun bloqueo
        numbloqueosmesacomb = RestaurantesBloqueo.getNumbloqueosmesacomb(@combinacion, @fecha.strftime("%F"), @hora.strftime("%T")).count

        # Revisamos si en el tiempo necesario para realizar esta reserva alguna mesa de esta combinación tiene algun bloqueo
        numbloqueosfuturosmesacomb = RestaurantesBloqueo.getNumbloqueosfuturosmesacomb(@combinacion, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T") ).count

        # Revisamos si alguna mesa de esta combinación está en otra combinacion que tiene algun bloqueo
        numbloqueosmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and fecha=? and hora=?", @salon, mesa, @fecha.strftime("%F"), @hora.strftime("%T"))
          numbloqueosmesaotracomb += restaurantesBloqueos.count
        end

        # Revisamos si en el tiempo necesario para realizar esta reserva alguna mesa de esta combinación está en otra combinacion que tiene algun bloqueo
        numbloqueosfuturosmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and fecha=? and hora>? and hora < ?", @salon, mesa, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
          numbloqueosfuturosmesaotracomb += restaurantesBloqueos.count
        end

        # comprobamos resultados -->
        if numreservascomb == 0 && numreservasfuturascomb == 0 && numreservasmesacomb == 0 && numreservasfuturasmesacomb == 0 && numreservasmesaotracomb == 0 && numreservasfuturasmesaotracomb == 0 && numbloqueoscomb == 0 && numbloqueosfuturoscomb == 0 && numbloqueosmesacomb == 0 && numbloqueosfuturosmesacomb == 0 && numbloqueosmesaotracomb == 0 && numbloqueosfuturosmesaotracomb == 0
          @combinacion = @idcombinacion
          break
        end
      end

      # Combinaciones con capacidad exacta
      restaurantesCombinaciones = RestaurantesCombinacione.find(:all,
        :select => "idcombinacion,salon,combinacion,plazas_min,plazas_max",
        :joins => "join restaurantes_salones on restaurantes_combinaciones.salon=restaurantes_salones.idsalon",
        :conditions => "restaurante='"+@restaurante.id.to_s+"' and visible='1' and plazas = '"+@personas.to_s+"' and mesafija='1' "
        )
      restaurantesCombinaciones.each do |restaurantesCombinacion|
        # Datos combinacion
        @idcombinacion = restaurantesCombinacion.idcombinacion
        @salon = restaurantesCombinacion.salon
        @combinacion = restaurantesCombinacion.combinacion
        @arraymesas = @combinacion.split(",")

        # Revisamos si en esta combinacion hay alguna reserva
        numreservascomb = RestaurantesReserva.getNumreservascomb(@idcombinacion, @fecha.strftime("%F"), @hora.strftime("%T")).count

        # Revisamos si en el tiempo necesario para realizar esta reserva hay alguna reserva en esta combinacion
        numreservasfuturascomb = RestaurantesReserva.getNumreservasfuturascomb(@idcombinacion, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T")).count

        # Revisamos si alguna mesa de esta combinación tiene alguna reserva
        numreservasmesacomb = RestaurantesReserva.getNumreservasmesacomb(@combinacion, @fecha.strftime("%F"), @hora.strftime("%T")).count

        # Revisamos si en el tiempo necesario para realizar esta reserva en alguna mesa de esta combinación hay alguna reserva
        numreservasfuturasmesacomb = RestaurantesReserva.getNumreservasfuturasmesacomb(@combinacion, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T")).count

        # Revisamos si alguna mesa de esta combinación está en otra combinacion que tiene alguna reserva
        numreservasmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @salon, mesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora.strftime("%T"))
          numreservasmesaotracomb += restaurantesReservas.count
        end

        # Revisamos si en el tiempo necesario para realizar esta reserva alguna mesa de esta combinación está en otra combinacion que tiene alguna reserva
        numreservasfuturasmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva>? and hora_reserva<?", @salon, mesa, 0, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
          numreservasfuturasmesaotracomb += restaurantesReservas.count
        end

        # Revisamos si en esta combinacion hay algun bloqueo
        numbloqueoscomb = RestaurantesBloqueo.getNumbloqueoscomb(@idcombinacion, @fecha.strftime("%F"), @hora.strftime("%T")).count

        # Revisamos si en el tiempo necesario para realizar esta reserva en esta combinacion hay algun bloqueo
        numbloqueosfuturoscomb = RestaurantesBloqueo.getNumbloqueosfuturoscomb(@idcombinacion, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T") ).count

        # Revisamos si alguna mesa de esta combinación tiene algun bloqueo
        numbloqueosmesacomb = RestaurantesBloqueo.getNumbloqueosmesacomb(@combinacion, @fecha.strftime("%F"), @hora.strftime("%T")).count

        # Revisamos si en el tiempo necesario para realizar esta reserva alguna mesa de esta combinación tiene algun bloqueo
        numbloqueosfuturosmesacomb = RestaurantesBloqueo.getNumbloqueosfuturosmesacomb(@combinacion, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T") ).count

        # Revisamos si alguna mesa de esta combinación está en otra combinacion que tiene algun bloqueo
        numbloqueosmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and fecha=? and hora=?", @salon, mesa, @fecha.strftime("%F"), @hora.strftime("%T"))
          numbloqueosmesaotracomb += restaurantesBloqueos.count
        end

        # Revisamos si en el tiempo necesario para realizar esta reserva alguna mesa de esta combinación está en otra combinacion que tiene algun bloqueo
        numbloqueosfuturosmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and fecha=? and hora>? and hora < ?", @salon, mesa, @fecha.strftime("%F"), @hora.strftime("%T"), @hora_nec.strftime("%T"))
          numbloqueosfuturosmesaotracomb += restaurantesBloqueos.count
        end

        # comprobamos resultados -->
        if numreservascomb == 0 && numreservasfuturascomb == 0 && numreservasmesacomb == 0 && numreservasfuturasmesacomb == 0 && numreservasmesaotracomb == 0 && numreservasfuturasmesaotracomb == 0 && numbloqueoscomb == 0 && numbloqueosfuturoscomb == 0 && numbloqueosmesacomb == 0 && numbloqueosfuturosmesacomb == 0 && numbloqueosmesaotracomb == 0 && numbloqueosfuturosmesaotracomb == 0
          @combinacion = @idcombinacion
          break
        end
      end

      if @mesa > 0 then @combinacion = 0 end
      @lespera = 0
      @ubicacion = 'm'+@mesa.to_s+'c'+@combinacion.to_s

    elsif @modoreservas == 1
    # Modo plazas
      @txtturno = Restaurante.getTurno(@turno)
      restaurantes_plazas = RestaurantesPlaza.all(
                  select:  @txtturno+" as plazas,
                           (select sum(comensales) from restaurantes_reservas where restaurante="+@restaurante.id.to_s+" and promocion='"+@idPromocion+"' and fecha_reserva='"+@fecha.strftime('%F').to_s+"' and turno='"+@txtturno+"' and cancelado='0') as usos",
                  conditions:  "restaurante='"+@restaurante.id.to_s+"' and fecha='"+@fecha.strftime('%F').to_s+"'").first
      plazas = restaurantes_plazas.plazas.to_i
      usos = restaurantes_plazas.usos.to_i

      if @personas <= (plazas - usos)
        @lespera = 0
      elsif @personas > (plazas - usos) && @restaurante.listaespera
        @lespera = 1
      end
      @ubicacion = 'm0c0'
      @combinacion = 0
      @mesa = 0
      @tiempo = 0
    end

    fecha_alta = Time.zone.now.strftime("%F")
    hora_alta = Time.zone.now.strftime("%T")

    if RestaurantesReserva.where(:restaurante => @restaurante.id, :fecha_reserva => @fecha.strftime("%F"), :hora_reserva => @hora.strftime("%T"), :comensales => @personas, :tipo_reserva => 1, :promocion => @idPromocion, :mesa => @mesa, :combinacion => @combinacion, :tiempo => @tiempo, :observaciones => @observaciones, :lespera => 0).exists?
      respond_with("Lleno") and return
    end

    # Comprobamos si está dado de alta en el restaurante seleccionado
    restUsuario = RestaurantesUsuario.where(:email => @user.email, :restaurante => @restaurante.id)

    if !restUsuario.exists?
      # TODO: Mirar el campo "medio". A lo mejor deberia ser Aviatur
      RestaurantesUsuario.create(:restaurante => @restaurante.id, :fecha => fecha_alta, :hora => hora_alta, :nombre => @user.nombre, :apellidos => @user.apellidos, :telefono => @user.telefono, :ciudad => @user.ciudad, :medio => @user.medio, :email => @user.email, :password => @user.password, :nota => "")
    end

    # TODO: Mirar el campo "partner". A lo mejor deberia ser Aviatur
    @restaurantesReservas = RestaurantesReserva.create(:restaurante => @restaurante.id, :usuario => @user.id_usuario, :lespera => @lespera, :widget => false, :partner => false, :fecha_alta => fecha_alta, :hora_alta => hora_alta, :fecha_reserva => @fecha.strftime("%F"), :hora_reserva => @hora.strftime("%T"), :comensales => @personas, :tipo_reserva => 1, :promocion => @idPromocion, :mesa => @mesa, :combinacion => @combinacion, :tiempo => @tiempo, :observaciones => @observaciones, :turno => Restaurante.getTurno(@turno))

    respond_to do |format|
      format.json { render json: @restaurantesReservas }
      format.xml { render '/app/views/api_mesafijas/rest_reserva_agregar.xml.builder' }
    end
  end

  # Servicio que permite cancelar una reserva mediante los datos proporcionados con el servicio usuario-datos.php
  def rest_reserva_cancelar
    rest_reserva = RestaurantesReserva.where(:id_reserva => params[:id_reserva])
    if rest_reserva.exists?
      rest_reserva.first.update_attributes(:cancelado => 1)

      showSuccess("Aceptado - Se ha cancelado la reserva correctamente") and return
    else
      showError("Denegado - No se ha podido cancelar la reserva") and return
    end
  end

  # Servicio que permite el reconocimiento del usuario
  def usuario_login
    showError("Correo electronico o contraseña vacio") and return if params[:email].blank? || params[:password].blank?

    @user = RestaurantesUsuario.where(:email => params[:email], :password => OpenSSL::HMAC.hexdigest('sha256', 'colombia', params[:password]) )

    if @user.exists?
      respond_to do |format|
        format.json { render json: @restaurantesReservas }
        format.xml { render '/app/views/api_mesafijas/usuario_login.xml.builder' }
      end
    else
      showError("Correo electronico o contraseña incorrecto") and return
    end

    # 6c4ad053e5c9b1a678e34c3d0bbfa82fd5b477f54e6a0fdba8595025c620e671 == 70887088
  end

  # Servicio que permite procesar la regeneración de password del usuario
  # TODO : Buscar como se hace
  def usuario_regpswd
    email = params[:email]
    clave = SecureRandom.hex(40)
    usuario = RestaurantesUsuario.where(:email => params[:email]).first

    if !usuario.nil?
      usuarioReg = UsuariosReg.create(:email => usuario.email, :clave => clave)

      # ApiMesafijaMailer.usuario_regpswd(usuarioReg).deliver
      showSuccess("Aceptado - Te hemos enviado un email") and return
    else
      showError("Denegado - Email not valid") and return
    end
  end

  # Servicio que permite el registro del usuario
  def usuario_registro
    if params[:nombre].blank?
      showError("Denegado - Falta nombre") and return
    elsif params[:apellidos].blank?
      showError("Denegado - Falta apellidos") and return
    elsif params[:telefono].blank?
      showError("Denegado - Falta telefono") and return
    elsif params[:ciudad].blank?
      showError("Denegado - Falta ciudad") and return
    elsif params[:email].blank?
      showError("Denegado - Falta email") and return
    elsif params[:password].blank?
      showError("Denegado - Falta password") and return
    elsif RestaurantesUsuario.where(:email => params[:email])
      showError("Denegado - Usuario ya existe") and return
    end

    @restauranteUsuario = RestaurantesUsuario.create(:fecha => Time.zone.now.strftime("%F"), :hora => Time.zone.now.strftime("%T"), :nombre => params[:nombre], :apellidos => params[:apellidos], :telefono => params[:telefono], :ciudad => params[:ciudad], :medio => params[:medio], :email => params[:email], :password => OpenSSL::HMAC.hexdigest('sha256', 'colombia', params[:password]) )

    if @restauranteUsuario.exists?
      respond_to do |format|
        format.json { render json: @restaurantesReservas }
        format.xml { render '/app/views/api_mesafijas/usuario_registro.xml.builder' }
      end
    else
      showError("Error - No se ha podido registrar el usuario") and return
    end
  end

  # Servicio que permite acceder a los datos de usuario
  def usuario_datos
    # Mirar en mi-cuenta.php
    showError("Denegado - Falta idUsuario") and return if params[:idUsuario].blank?
    user = RestaurantesUsuario.where(:id_usuario => params[:idUsuario]).first
    showError("Denegado - No existe el usuario con id : "+params[:idUsuario]) and return if user.nil?
    @result = {
      "id" => user.id_usuario,
      "nombre" => user.nombre,
      "apellidos" => user.apellidos,
      "telefono" => user.telefono,
      "ciudad" => user.ciudad,
      "email" => user.email,
      "numReservasPendientes" => user.getReservasPendientes.count,
      "numReservasRealizadas" => user.getReservasRealizadas.count,
      "numComentariosRealizados" => user.getNumComentariosRealizados,
      "reservasPendientes" => user.getReservasPendientes,
      "reservasRealizadas" => user.getReservasRealizadas,
      "favoritos" => user.getFavoritos
    }
    # TODO : Hacer la funcion de getReservasPendientes, getReservasRealizadas, getFavoritos, getNumComentariosRealizados que esta en restaurante_usuario.rb
    respond_to do |format|
      format.json { render json: @restaurantesReservas }
      format.xml { render '/app/views/api_mesafijas/usuario_datos.xml.builder' }
    end
  end

  # Servicio que permite editar los datos de usuario mediante los datos proporcionados con el servicio usuario-datos.php
  def usuario_editar
    restauranteUsuario = RestaurantesUsuario.where(:id_usuario => params[:idUsuario]).first

    showError("Denegado - No existe el usuario con id : "+params[:idUsuario]) and return if restauranteUsuario.nil?

    restauranteUsuario.update_attributes(:nombre => params[:nombre]) unless params[:nombre].blank?
    restauranteUsuario.update_attributes(:apellidos => params[:apellidos]) unless params[:apellidos].blank?
    restauranteUsuario.update_attributes(:telefono => params[:telefono]) unless params[:telefono].blank?
    restauranteUsuario.update_attributes(:ciudad => params[:ciudad]) unless params[:ciudad].blank?
    restauranteUsuario.update_attributes(:email => params[:email]) unless params[:email].blank?

    showSuccess("Aceptado - Usuario actualizado correctamente") and return
  end

  # Servicio que permite valorar un restaurante por el usuario mediante los datos proporcionados con el servicio usuario-datos.php
  def valoracion
    # Mirar en funciones-ajax.php, en 'case "opinion": //Opinión - Insertar'

    if params[:idRestaurante].blank?
      showError("Denegado - Falta idRestaurante") and return
    elsif params[:idUsuario].blank?
      showError("Denegado - Falta idUsuario") and return
    elsif params[:idReserva].blank?
      showError("Denegado - Falta idReserva") and return
    end

    opinion = RestaurantesOpinione.where(:restaurante => params[:idRestaurante], :usuario => params[:idUsuario], :reserva => params[:idReserva])

    if params[:valorCocina].blank?
      showError("Denegado - Falta valorCocina") and return
    elsif params[:valorAmbiente].blank?
      showError("Denegado - Falta valorAmbiente") and return
    elsif params[:valorCalidadPrecio].blank?
      showError("Denegado - Falta valorCalidadPrecio") and return
    elsif params[:valorServicio].blank?
      showError("Denegado - Falta valorServicio") and return
    elsif params[:valorLimpieza].blank?
      showError("Denegado - Falta valorLimpieza") and return
    elsif params[:comentario].blank?
      showError("Denegado - Falta comentario") and return
    elsif opinion.exists?
      showError("Denegado - Ya valorado") and return
    end

    success = RestaurantesOpinione.create(:restaurante => params[:idRestaurante], :usuario => params[:idUsuario], :reserva => params[:idReserva], :fecha => Time.zone.now.strftime("Y-m-d"), :favorito => 0, :cocina => params[:valorCocina], :ambiente => params[:valorAmbiente], :calidadprecio => params[:valorCalidadPrecio], :servicio => params[:valorServicio], :limpieza => params[:valorLimpieza], :comentario => params[:comentario])
    if success
      RestaurantesReserva.where(:restaurante => params[:idRestaurante], :usuario => params[:idUsuario], :reserva => params[:idReserva]).update_all(:comentado => true)
      showSuccess("Aceptado - Valoracion ha sido creada correctamente") and return
    else
      showError("Error - interno") and return
    end
  end

  # Servicio que permite marcar un restaurante como favorito por el usuario mediante los datos proporcionados con el servicio usuario-datos.php
  def usuario_favorito_agregar
    # Mirar en funciones-ajax.php, en 'case "agregar-favorito": //Añadir favorito'

    if params[:idUsuario].blank?
      showError("Denegado - Falta idUsuario") and return
    elsif params[:idRestaurante].blank?
      showError("Denegado - Falta idRestaurante") and return
    end

    favorito = RestaurantesFavorito.where(:usuario => params[:idUsuario], :restaurante => params[:idRestaurante])

    showError("Denegado - Este restaurante ya es favorito") and return if favorito.exists?
    if RestaurantesFavorito.create(:usuario => params[:idUsuario], :restaurante => params[:idRestaurante])
      showSuccess("Aceptado - El restaurante ha sido agregado en favoritos") and return
    else
      showError("Denegado - No se ha podido añadir a favoritos") and return
    end
  end

  # Servicio que permite desmarcar un restaurante como favorito por el usuario mediante los datos proporcionados con el servicio usuario-datos.php
  def usuario_favorito_eliminar
    # Si nos pasa el idFavorito, lo borramos directamente
    if !params[:idFavorito].blank?
      restFavorito = RestaurantesFavorito.where(:idFavorito => params[:idFavorito])
      showError("Denegado - Este restaurante no esta como favorito") and return if !restFavorito.exists?
      restFavorito.first.delete
    elsif !params[:idUsuario].blank? && !params[:idRestaurante].blank?
      restFavorito = RestaurantesFavorito.where(:usuario => params[:idUsuario], :restaurante => params[:idRestaurante])
      showError("Denegado - Este restaurante no esta como favorito") and return if !restFavorito.exists?
      restFavorito.first.delete
    else
      showError("Denegado - Necesita (idUsuario + idRestaurante) o bien directamente idFavorito") and return
    end

    favorito = RestaurantesFavorito.where(:usuario => params[:idUsuario], :restaurante => params[:idRestaurante])
    # TODO : En la documentacion falta poner que tb puedes buscar por idUsuario

    showSuccess("Aceptado - El restaurante ha sido eliminado de la lista de favoritos") and return
  end

  # Servicio que permite listar todas las preguntas frecuentes
  def preguntas
    # Buscar por "seccion='5'" en la tabla de secciones

    categorias = SeccionesListCat.order("orden ASC").where(:seccion => 5, :activo => true)

    @result = []
    categorias.each do |categoria|
      @result << {
        "idCategoria" => categoria.idcategoria,
        "nombre" => categoria.categoriaes,
        "listadoPreguntas" => categoria.getListadoPreguntas
      }
    end

    respond_to do |format|
      format.json { render json: @result }
      format.xml { render '/app/views/api_mesafijas/preguntas.xml.builder' }
    end
  end

  private
    # TODO : Al poner formato XML, el respond_with(false) no funciona por ejemplo en el login
    def default_format_xml
      request.format = "xml"
      request.format = "json" if params[:sort_by] == "json"
    end

    def default_format_json
      request.format = "json"
      request.format = "xml" if params[:sort_by] == "xml"
    end

    def check_idCliente
      # params[:idCliente] = "9a6e722979ef40985214088c5a3dfb77515201d79b49b7f90df8e03a10dbc9cbe"
      showError("Acceso denegado - Necesitas identificarte") and return if params[:idCliente].blank?
      idCliente = params[:idCliente][0]
      hash = params[:idCliente]

      if (idCliente + OpenSSL::HMAC.hexdigest('sha256', 'colombia', idCliente)) == hash
        params[:idCliente] = idCliente
      else
        showError("Acceso denegado - Necesitas identificarte") and return
      end
    end

    def showError(error_txt)
      @error = error_txt
      respond_with do |format|
        format.json { render json: @error }
        format.xml { render '/app/views/api_mesafijas/error.xml.builder' }
      end
    end

    def showSuccess(success_txt)
      @success = success_txt
      respond_with do |format|
        format.json { render json: @success }
        format.xml { render '/app/views/api_mesafijas/success.xml.builder' }
      end
    end

    def getLetraDia(time)
      return "l" if time.monday?
      return "m" if time.tuesday?
      return "x" if time.wednesday?
      return "j" if time.thursday?
      return "v" if time.friday?
      return "s" if time.saturday?
      return "d" if time.sunday?
    end

    def aperturaPromo
      if !@promo.nil?
        promosnummax = @promo.promociones_max
        promospersmin = @promo.comensales_min
        promospersmax = @promo.comensales_max

        # byebug
        restaurantesReservas = RestaurantesReserva.select("sum(comensales) as usos").where(:restaurante => @restaurante.id.to_s, :promocion => @idPromocion, :cancelado => 0).first
        usos = restaurantesReservas.usos unless restaurantesReservas.nil?
        promosnummax = promosnummax - usos.to_i
        if promosnummax < promospersmax
          promospersmax = promosnummax
        end

        @arrayplazaspromo = Array.new
        numplazaspromo = promospersmin
        while numplazaspromo <= promospersmax do
          @arrayplazaspromo << numplazaspromo
          numplazaspromo += 1
        end
      end
    end

    def getMinimoPlazasRestaurante
      if @modoreservas == 0
        restaurantesMesas = RestaurantesMesa.find(:all,
          :select => "min(plazas_min) as plazasminmesas",
          :joins => "join restaurantes_salones on restaurantes_mesas.salon=restaurantes_salones.idsalon",
          :conditions => "restaurantes_salones.restaurante='"+@restaurante.id.to_s+"' and restaurantes_salones.visible=1"
          )
        plazasminmesas = restaurantesMesas.first.plazasminmesas.to_i

        restaurantesCombinaciones = RestaurantesCombinacione.find(:all,
          :select => "min(plazas_min) as plazasmincombinaciones",
          :joins => "join restaurantes_salones on restaurantes_combinaciones.salon=restaurantes_salones.idsalon",
          :conditions => "restaurantes_salones.restaurante='"+@restaurante.id.to_s+"' and restaurantes_salones.visible=1"
          )
        plazasmincombinaciones = restaurantesCombinaciones.first.plazasmincombinaciones.to_i

        if plazasmincombinaciones < plazasminmesas
          return plazasmincombinaciones
        else
          return plazasminmesas
        end
      end
    end

    def getMaximoPlazasRestaurante
      if @modoreservas == 0
        restaurantesMesas = RestaurantesMesa.find(:all,
          :select => "max(plazas_max) as plazasmaxmesas",
          :joins => "join restaurantes_salones on restaurantes_mesas.salon=restaurantes_salones.idsalon",
          :conditions => "restaurantes_salones.restaurante='"+@restaurante.id.to_s+"' and restaurantes_salones.visible=1"
          )
        plazasmaxmesas = restaurantesMesas.first.plazasmaxmesas.to_i

        restaurantesCombinaciones = RestaurantesCombinacione.find(:all,
          :select => "max(plazas_max) as plazasmaxcombinaciones",
          :joins => "join restaurantes_salones on restaurantes_combinaciones.salon=restaurantes_salones.idsalon",
          :conditions => "restaurantes_salones.restaurante='"+@restaurante.id.to_s+"' and restaurantes_salones.visible=1"
          )
        plazasmaxcombinaciones = restaurantesCombinaciones.first.plazasmaxcombinaciones.to_i

        if plazasmaxcombinaciones > plazasmaxmesas
          return plazasmaxcombinaciones
        else
          return plazasmaxmesas
        end
      end
    end

    def tiempoPorMesaPersonas
      if @modoreservas == 0
        restaurantesTiempos = RestaurantesTiempo.select("least(tiempo_1,tiempo_2,tiempo_3,tiempo_4,tiempo_5,tiempo_6,tiempo_7,tiempo_8,tiempo_9,tiempo_10,tiempo_grupos) as tiempo_minimo").where(:restaurante => @restaurante.id).first

        @tiempo_minimo = restaurantesTiempos.tiempo_minimo.hour.hour + restaurantesTiempos.tiempo_minimo.min.minutes

        restaurantesTiempos = RestaurantesTiempo.where(:restaurante => @restaurante.id).first
        @bloques_1 = (restaurantesTiempos.tiempo_1.hour.hour + restaurantesTiempos.tiempo_1.min.minutes) / 1800
        @bloques_2 = (restaurantesTiempos.tiempo_2.hour.hour + restaurantesTiempos.tiempo_2.min.minutes) / 1800
        @bloques_3 = (restaurantesTiempos.tiempo_3.hour.hour + restaurantesTiempos.tiempo_3.min.minutes) / 1800
        @bloques_4 = (restaurantesTiempos.tiempo_4.hour.hour + restaurantesTiempos.tiempo_4.min.minutes) / 1800
        @bloques_5 = (restaurantesTiempos.tiempo_5.hour.hour + restaurantesTiempos.tiempo_5.min.minutes) / 1800
        @bloques_6 = (restaurantesTiempos.tiempo_6.hour.hour + restaurantesTiempos.tiempo_6.min.minutes) / 1800
        @bloques_7 = (restaurantesTiempos.tiempo_7.hour.hour + restaurantesTiempos.tiempo_7.min.minutes) / 1800
        @bloques_8 = (restaurantesTiempos.tiempo_8.hour.hour + restaurantesTiempos.tiempo_8.min.minutes) / 1800
        @bloques_9 = (restaurantesTiempos.tiempo_9.hour.hour + restaurantesTiempos.tiempo_9.min.minutes) / 1800
        @bloques_10 = (restaurantesTiempos.tiempo_10.hour.hour + restaurantesTiempos.tiempo_10.min.minutes) / 1800
        @bloques_g = (restaurantesTiempos.tiempo_grupos.hour.hour + restaurantesTiempos.tiempo_grupos.min.minutes) / 1800
      end
    end

    def tiempoPorMesaTurno
      @tiempo_minimo = 0
      if @modoreservas == 0
        restaurantesTiempos = RestaurantesTiempo.select("least(tiempo_1,tiempo_2,tiempo_3,tiempo_4,tiempo_5,tiempo_6,tiempo_7,tiempo_8,tiempo_9,tiempo_10,tiempo_grupos) as tiempo_minimo").where(:restaurante => @restaurante.id).first

        @tiempo_minimo = restaurantesTiempos.tiempo_minimo.hour.hour + restaurantesTiempos.tiempo_minimo.min.minutes

        restaurantesTiempos = RestaurantesTiempo.where(:restaurante => @restaurante.id).first
        if @personas.to_i > 10
          # Igual que @bloques_g
          @bloques_nec = (restaurantesTiempos.tiempo_grupos.hour.hour + restaurantesTiempos.tiempo_grupos.min.minutes) / 1800
        else
          @bloques_nec = (restaurantesTiempos["tiempo_"+@personas.to_s].hour.hour + restaurantesTiempos["tiempo_"+@personas.to_s].min.minutes) / 1800
        end
      end
    end

    def datosHorarios
      @abierto_break = @restaurante['break_'+@letraDia]
      @abierto_almuerzo = @restaurante['almuerzo_'+@letraDia]
      @abierto_onces = @restaurante['onces_'+@letraDia]
      @abierto_cena = @restaurante['cena_'+@letraDia]

      @apertura_break = @restaurante['break_'+@letraDia+'_a']
      @apertura_break = @fecha.change({:hour => @apertura_break.hour, :min => @apertura_break.min }) + (@apertura_break.day - 1).day
      @apertura_almuerzo = @restaurante['almuerzo_'+@letraDia+'_a']
      @apertura_almuerzo = @fecha.change({:hour => @apertura_almuerzo.hour, :min => @apertura_almuerzo.min }) + (@apertura_almuerzo.day - 1).day
      @apertura_onces = @restaurante['onces_'+@letraDia+'_a']
      @apertura_onces = @fecha.change({:hour => @apertura_onces.hour, :min => @apertura_onces.min }) + (@apertura_onces.day - 1).day
      @apertura_cena = @restaurante['cena_'+@letraDia+'_a']
      @apertura_cena = @fecha.change({:hour => @apertura_cena.hour, :min => @apertura_cena.min }) + (@apertura_cena.day - 1).day

      @cierre_break = @restaurante['break_'+@letraDia+'_c']
      @cierre_break = @fecha.change({:hour => @cierre_break.hour, :min => @cierre_break.min }) + (@cierre_break.day - 1).day
      @cierre_almuerzo = @restaurante['almuerzo_'+@letraDia+'_c']
      @cierre_almuerzo = @fecha.change({:hour => @cierre_almuerzo.hour, :min => @cierre_almuerzo.min }) + (@cierre_almuerzo.day - 1).day
      @cierre_onces = @restaurante['onces_'+@letraDia+'_c']
      @cierre_onces = @fecha.change({:hour => @cierre_onces.hour, :min => @cierre_onces.min }) + (@cierre_onces.day - 1).day
      @cierre_cena = @restaurante['cena_'+@letraDia+'_c']
      @cierre_cena = @fecha.change({:hour => @cierre_cena.hour, :min => @cierre_cena.min }) + (@cierre_cena.day - 1).day

      @horario_break = @cierre_break.to_i - @apertura_break.to_i
      @horario_almuerzo = @cierre_almuerzo.to_i - @apertura_almuerzo.to_i
      @horario_onces = @cierre_onces.to_i - @apertura_onces.to_i
      @horario_cena = @cierre_cena.to_i - @apertura_cena.to_i
    end

    def getTiempoApertura
      tiempoapertura = 0
      if @abierto_break == 1 && @horario_break >= @tiempo_minimo then tiempoapertura += @horario_break end
      if @abierto_almuerzo == 1 && @horario_almuerzo >= @tiempo_minimo then tiempoapertura += @horario_almuerzo end
      if @abierto_onces == 1 && @horario_onces >= @tiempo_minimo then tiempoapertura += @horario_onces end
      if @abierto_cena == 1 && @horario_cena >= @tiempo_minimo then tiempoapertura += @horario_cena end
      return tiempoapertura
    end

    def getPlazasDisponiblesPersonas
      bloques = [@maxbloquesbreak,@maxbloquesalmuerzo,@maxbloquesonces,@maxbloquescena].max
      numplazas = @plazas_min
      while numplazas <= @plazas_max
        if numplazas == 1
          if @bloques_1.hour <= bloques.hour then @arrayplazas << numplazas end
        elsif numplazas == 2
          if @bloques_2.hour <= bloques.hour then @arrayplazas << numplazas end
        elsif numplazas == 3
          if @bloques_3.hour <= bloques.hour then @arrayplazas << numplazas end
        elsif numplazas == 4
          if @bloques_4.hour <= bloques.hour then @arrayplazas << numplazas end
        elsif numplazas == 5
          if @bloques_5.hour <= bloques.hour then @arrayplazas << numplazas end
        elsif numplazas == 6
          if @bloques_6.hour <= bloques.hour then @arrayplazas << numplazas end
        elsif numplazas == 7
          if @bloques_7.hour <= bloques.hour then @arrayplazas << numplazas end
        elsif numplazas == 8
          if @bloques_8.hour <= bloques.hour then @arrayplazas << numplazas end
        elsif numplazas == 9
          if @bloques_9.hour <= bloques.hour then @arrayplazas << numplazas end
        elsif numplazas == 10
          if @bloques_10.hour <= bloques.hour then @arrayplazas << numplazas end
        elsif numplazas > 10
          if @bloques_g.hour <= bloques.hour then @arrayplazas << numplazas end
        end
        numplazas += 1
      end
    end

    def getPlazasDisponiblesTurno
      if @bloques_nec <= @maxbloquesbreak then @mesasbreak = 1 end
      if @bloques_nec <= @maxbloquesalmuerzo then @mesasalmuerzo = 1 end
      if @bloques_nec <= @maxbloquesonces then @mesasonces = 1 end
      if @bloques_nec <= @maxbloquescena then @mesascena = 1 end
    end

    def arrayParrilla
      @arraybreak = Array.new
      if @abierto_break == 1 && @horario_break >= @tiempo_minimo
        horaparrilla = @apertura_break
        while horaparrilla < @cierre_break do
          unless @fecha == Time.zone.today && horaparrilla.to_i < @bloqueo_hora
            @arraybreak << horaparrilla.strftime("%T")
          end
          horaparrilla += 1800
        end
      end

      @arrayalmuerzo = Array.new
      if @abierto_almuerzo == 1 && @horario_almuerzo >= @tiempo_minimo
        horaparrilla = @apertura_almuerzo
        while horaparrilla < @cierre_almuerzo do
          unless @fecha == Time.zone.today && horaparrilla.to_i < @bloqueo_hora
            @arrayalmuerzo << horaparrilla.strftime("%T")
          end
          horaparrilla += 1800
        end
      end

      @arrayonces = Array.new
      if @abierto_onces == 1 && @horario_onces >= @tiempo_minimo
        horaparrilla = @apertura_onces
        while horaparrilla < @cierre_onces do
          unless @fecha == Time.zone.today && horaparrilla.to_i < @bloqueo_hora
            @arrayonces << horaparrilla.strftime("%T")
          end
          horaparrilla += 1800
        end
      end

      @arraycena = Array.new
      if @abierto_cena == 1 && @horario_cena >= @tiempo_minimo
        horaparrilla = @apertura_cena
        while horaparrilla < @cierre_cena do
          unless @fecha == Time.zone.today && horaparrilla.to_i < @bloqueo_hora
            @arraycena << horaparrilla.strftime("%T")
          end
          horaparrilla += 1800
        end
      end
    end

    def calculoBreak
      @arraybreak.each do |elementBreak|
        # Revisamos si en esta mesa y en este bloque hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("mesa = ? and cancelado = ? and fecha_reserva = ? and hora_reserva <= ? and addtime(hora_reserva,tiempo) > ?", @idmesa, 0, @fecha.strftime("%F"), elementBreak, elementBreak)
        numreservasmesa = restaurantesReservas.count

        # Revisamos si en una combinación con esta mesa y en este bloque hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @idmesa, 0, @fecha.strftime("%F"), elementBreak, elementBreak)
        numreservascomb = restaurantesReservas.count

        # Revisamos si en esta mesa y en este bloque hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where(:mesa => @idmesa, :fecha => @fecha.strftime("%F"), :hora => elementBreak)
        numbloqueosmesa = restaurantesBloqueos.count

        # Revisamos si en una combinación con esta mesa y en este bloque hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and fecha=? and hora=?", @idmesa, @fecha.strftime("%F"), elementBreak)
        numbloqueoscomb = restaurantesBloqueos.count

        # Comprobamos resultados
        if numreservasmesa == 0 && numreservascomb == 0 && numbloqueosmesa == 0 && numbloqueoscomb == 0
          @bloquesbreak += 1
          @maxbloquesbreak = @bloquesbreak if @bloquesbreak >= @maxbloquesbreak
        else
          @bloquesbreak = 0
        end
      end
    end

    def calculoAlmuerzo
      @arrayalmuerzo.each do |elementAlmuerzo|
        # Revisamos si en esta mesa y en este bloque hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("mesa = ? and cancelado = ? and fecha_reserva = ? and hora_reserva <= ? and addtime(hora_reserva,tiempo) > ?", @idmesa, 0, @fecha.strftime("%F"), elementAlmuerzo, elementAlmuerzo)
        numreservasmesa = restaurantesReservas.count

        # Revisamos si en una combinación con esta mesa y en este bloque hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @idmesa, 0, @fecha.strftime("%F"), elementAlmuerzo, elementAlmuerzo)
        numreservascomb = restaurantesReservas.count

        # Revisamos si en esta mesa y en este bloque hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where(:mesa => @idmesa, :fecha => @fecha.strftime("%F"), :hora => elementAlmuerzo)
        numbloqueosmesa = restaurantesBloqueos.count

        # Revisamos si en una combinación con esta mesa y en este bloque hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and fecha=? and hora=?", @idmesa, @fecha.strftime("%F"), elementAlmuerzo)
        numbloqueoscomb = restaurantesBloqueos.count

        # Comprobamos resultados
        if numreservasmesa == 0 && numreservascomb == 0 && numbloqueosmesa == 0 && numbloqueoscomb == 0
          @bloquesalmuerzo += 1
          @maxbloquesalmuerzo = @bloquesalmuerzo if @bloquesalmuerzo >= @maxbloquesalmuerzo
        else
          @bloquesalmuerzo = 0
        end
      end
    end

    def calculoOnce
      @arrayonces.each do |elementOnce|
        # Revisamos si en esta mesa y en este bloque hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("mesa = ? and cancelado = ? and fecha_reserva = ? and hora_reserva <= ? and addtime(hora_reserva,tiempo) > ?", @idmesa, 0, @fecha.strftime("%F"), elementOnce, elementOnce)
        numreservasmesa = restaurantesReservas.count

        # Revisamos si en una combinación con esta mesa y en este bloque hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @idmesa, 0, @fecha.strftime("%F"), elementOnce, elementOnce)
        numreservascomb = restaurantesReservas.count

        # Revisamos si en esta mesa y en este bloque hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where(:mesa => @idmesa, :fecha => @fecha.strftime("%F"), :hora => elementOnce)
        numbloqueosmesa = restaurantesBloqueos.count

        # Revisamos si en una combinación con esta mesa y en este bloque hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and fecha=? and hora=?", @idmesa, @fecha.strftime("%F"), elementOnce)
        numbloqueoscomb = restaurantesBloqueos.count

        # Comprobamos resultados
        if numreservasmesa == 0 && numreservascomb == 0 && numbloqueosmesa == 0 && numbloqueoscomb == 0
          @bloquesonces += 1
          @maxbloquesonces = @bloquesonces if @bloquesonces >= @maxbloquesonces
        else
          @bloquesonces = 0
        end
      end
    end

    def calculoCena
      @arraycena.each do |elementCena|
        # Revisamos si en esta mesa y en este bloque hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("mesa = ? and cancelado = ? and fecha_reserva = ? and hora_reserva <= ? and addtime(hora_reserva,tiempo) > ?", @idmesa, 0, @fecha.strftime("%F"), elementCena, elementCena)
        numreservasmesa = restaurantesReservas.count

        # Revisamos si en una combinación con esta mesa y en este bloque hay alguna reserva
        restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @idmesa, 0, @fecha.strftime("%F"), elementCena, elementCena)
        numreservascomb = restaurantesReservas.count

        # Revisamos si en esta mesa y en este bloque hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where(:mesa => @idmesa, :fecha => @fecha.strftime("%F"), :hora => elementCena)
        numbloqueosmesa = restaurantesBloqueos.count

        # Revisamos si en una combinación con esta mesa y en este bloque hay algun bloqueo
        restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where locate(?,combinacion)>0) and fecha=? and hora=?", @idmesa, @fecha.strftime("%F"), elementCena)
        numbloqueoscomb = restaurantesBloqueos.count

        # Comprobamos resultados
        if numreservasmesa == 0 && numreservascomb == 0 && numbloqueosmesa == 0 && numbloqueoscomb == 0
          @bloquescena += 1
          @maxbloquescena = @bloquescena if @bloquescena >= @maxbloquescena
        else
          @bloquescena = 0
        end
      end
    end

    def calculoBreakCombinacion
      @arraybreak.each do |elementBreak|
        # Revisamos si en esta combinacion y en este bloque hay alguna reserva
        numreservascomb = RestaurantesReserva.getNumreservascomb(@idcombinacion, @fecha.strftime("%F"), elementBreak).count

        # Revisamos si alguna mesa de esta combinación en este bloque tiene alguna reserva
        numreservasmesacomb = RestaurantesReserva.getNumreservasmesacomb(@combinacion, @fecha.strftime("%F"), elementBreak).count

        # Revisamos si alguna mesa de esta combinación en este bloque está en otra combinacion que tiene alguna reserva
        numreservasmesaotracomb = 0
        arraymesas.each do |mesa|
          restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @salon, mesa, 0, @fecha.strftime("%F"), elementBreak, elementBreak)
          numreservasmesaotracomb += restaurantesReservas.count
        end

        # Revisamos si en esta combinacion y en este bloque hay algun bloqueo
        numbloqueoscomb = RestaurantesBloqueo.getNumbloqueoscomb(@idcombinacion, @fecha.strftime("%F"), elementBreak).count

        # Revisamos si alguna mesa de esta combinación en este bloque tiene algun bloqueo
        numbloqueosmesacomb = RestaurantesBloqueo.getNumbloqueosmesacomb(@combinacion, @fecha.strftime("%F"), elementBreak).count

        # Revisamos si alguna mesa de esta combinación en este bloque está en otra combinacion que tiene algun bloqueo
        numbloqueosmesaotracomb = 0
        arraymesas.each do |mesa|
          restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and fecha=? and hora=?", @salon, mesa, @fecha.strftime("%F"), elementBreak)
          numbloqueosmesaotracomb += restaurantesBloqueos.count
        end

        # Comprobamos resultados
        if numreservascomb == 0 && numreservasmesacomb == 0 && numreservasmesaotracomb == 0 && numbloqueoscomb == 0 && numbloqueosmesacomb == 0 && numbloqueosmesaotracomb == 0
          @bloquesbreak += 1
          @maxbloquesbreak = @bloquesbreak if @bloquesbreak >= @maxbloquesbreak
        else
          @bloquesbreak = 0
        end
      end
    end

    def calculoAlmuerzoCombinacion
      @arrayalmuerzo.each do |elementAlmuerzo|
        # Revisamos si en esta combinacion y en este bloque hay alguna reserva
        numreservascomb = RestaurantesReserva.getNumreservascomb(@idcombinacion, @fecha.strftime("%F"), elementAlmuerzo).count

        # Revisamos si alguna mesa de esta combinación en este bloque tiene alguna reserva
        numreservasmesacomb = RestaurantesReserva.getNumreservasmesacomb(@combinacion, @fecha.strftime("%F"), elementAlmuerzo).count

        # Revisamos si alguna mesa de esta combinación en este bloque está en otra combinacion que tiene alguna reserva
        numreservasmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @salon, mesa, 0, @fecha.strftime("%F"), elementAlmuerzo, elementAlmuerzo)
          numreservasmesaotracomb += restaurantesReservas.count
        end

        # Revisamos si en esta combinacion y en este bloque hay algun bloqueo
        numbloqueoscomb = RestaurantesBloqueo.getNumbloqueoscomb(@idcombinacion, @fecha.strftime("%F"), elementAlmuerzo).count

        # Revisamos si alguna mesa de esta combinación en este bloque tiene algun bloqueo
        numbloqueosmesacomb = RestaurantesBloqueo.getNumbloqueosmesacomb(@combinacion, @fecha.strftime("%F"), elementAlmuerzo).count

        # Revisamos si alguna mesa de esta combinación en este bloque está en otra combinacion que tiene algun bloqueo
        numbloqueosmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and fecha=? and hora=?", @salon, mesa, @fecha.strftime("%F"), elementAlmuerzo)
          numbloqueosmesaotracomb += restaurantesBloqueos.count
        end

        if numreservascomb == 0 && numreservasmesacomb == 0 && numreservasmesaotracomb == 0 && numbloqueoscomb == 0 && numbloqueosmesacomb == 0 && numbloqueosmesaotracomb == 0
          @bloquesalmuerzo += 1
          @maxbloquesalmuerzo = @bloquesalmuerzo if @bloquesalmuerzo >= @maxbloquesalmuerzo
        else
          @bloquesalmuerzo = 0
        end
      end
    end

    def calculoOnceCombinacion
      @arrayonces.each do |elementOnce|
        # Revisamos si en esta combinacion y en este bloque hay alguna reserva
        numreservascomb = RestaurantesReserva.getNumreservascomb(@idcombinacion, @fecha.strftime("%F"), elementOnce).count

        # Revisamos si alguna mesa de esta combinación en este bloque tiene alguna reserva
        numreservasmesacomb = RestaurantesReserva.getNumreservasmesacomb(@combinacion, @fecha.strftime("%F"), elementOnce).count

        # Revisamos si alguna mesa de esta combinación en este bloque está en otra combinacion que tiene alguna reserva
        numreservasmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @salon, mesa, 0, @fecha.strftime("%F"), elementOnce, elementOnce)
          numreservasmesaotracomb += restaurantesReservas.count
        end

        # Revisamos si en esta combinacion y en este bloque hay algun bloqueo
        numbloqueoscomb = RestaurantesBloqueo.getNumbloqueoscomb(@idcombinacion, @fecha.strftime("%F"), elementOnce).count

        # Revisamos si alguna mesa de esta combinación en este bloque tiene algun bloqueo
        numbloqueosmesacomb = RestaurantesBloqueo.getNumbloqueosmesacomb(@combinacion, @fecha.strftime("%F"), elementOnce).count

        # Revisamos si alguna mesa de esta combinación en este bloque está en otra combinacion que tiene algun bloqueo
        numbloqueosmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and fecha=? and hora=?", @salon, mesa, @fecha.strftime("%F"), elementOnce)
          numbloqueosmesaotracomb += restaurantesBloqueos.count
        end

        # Comprobamos resultados
        if numreservascomb == 0 && numreservasmesacomb == 0 && numreservasmesaotracomb == 0 && numbloqueoscomb == 0 && numbloqueosmesacomb == 0 && numbloqueosmesaotracomb == 0
          @bloquesonces += 1
          @maxbloquesonces = @bloquesonces if @bloquesonces >= @maxbloquesonces
        else
          @bloquesonces = 0
        end
      end
    end

    def calculoCenaCombinacion
      @arraycena.each do |elementCena|
        # Revisamos si en esta combinacion y en este bloque hay alguna reserva
        numreservascomb = RestaurantesReserva.getNumreservascomb(@idcombinacion, @fecha.strftime("%F"), elementCena).count

        # Revisamos si alguna mesa de esta combinación en este bloque tiene alguna reserva
        numreservasmesacomb = RestaurantesReserva.getNumreservasmesacomb(@combinacion, @fecha.strftime("%F"), elementCena).count

        # Revisamos si alguna mesa de esta combinación en este bloque está en otra combinacion que tiene alguna reserva
        numreservasmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesReservas = RestaurantesReserva.select("hora_reserva").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", @salon, mesa, 0, @fecha.strftime("%F"), elementCena, elementCena)
          numreservasmesaotracomb += restaurantesReservas.count
        end

        # Revisamos si en esta combinacion y en este bloque hay algun bloqueo
        numbloqueoscomb = RestaurantesBloqueo.getNumbloqueoscomb(@idcombinacion, @fecha.strftime("%F"), elementCena).count

        # Revisamos si alguna mesa de esta combinación en este bloque tiene algun bloqueo
        numbloqueosmesacomb = RestaurantesBloqueo.getNumbloqueosmesacomb(@combinacion, @fecha.strftime("%F"), elementCena).count

        # Revisamos si alguna mesa de esta combinación en este bloque está en otra combinacion que tiene algun bloqueo
        numbloqueosmesaotracomb = 0
        @arraymesas.each do |mesa|
          restaurantesBloqueos = RestaurantesBloqueo.select("hora").where("combinacion in (select idcombinacion from restaurantes_combinaciones where salon = ? and locate(?,combinacion)>0) and fecha=? and hora=?", @salon, mesa, @fecha.strftime("%F"), elementCena)
          numbloqueosmesaotracomb += restaurantesBloqueos.count
        end

        # Comprobamos resultados
        if numreservascomb == 0 && numreservasmesacomb == 0 && numreservasmesaotracomb == 0 && numbloqueoscomb == 0 && numbloqueosmesacomb == 0 && numbloqueosmesaotracomb == 0
          @bloquescena += 1
          @maxbloquescena = @bloquescena if @bloquescena >= @maxbloquescena
        else
          @bloquescena = 0
        end
      end
    end
end
