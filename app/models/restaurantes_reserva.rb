class RestaurantesReserva < ActiveRecord::Base

    self.primary_key = :id_reserva

    def self.getNumreservascomb(idcombinacion, fecha, hora_reserva, turno = nil)
    	if turno.nil?
    		RestaurantesReserva.select("hora_reserva").where("combinacion = ? and cancelado = ? and fecha_reserva = ? and hora_reserva <= ? and addtime(hora_reserva,tiempo) > ?", idcombinacion, 0, fecha, hora_reserva, hora_reserva)
    	else
    		RestaurantesReserva.select("hora_reserva").where("combinacion = ? and cancelado = ? and fecha_reserva = ? and hora_reserva <= ? and addtime(hora_reserva,tiempo) > ? and turno = ?", idcombinacion, 0, fecha, hora_reserva, hora_reserva, turno)
    	end
    end

    def self.getNumreservasfuturascomb(idcombinacion, fecha, hora_reserva, hora_nec, turno = nil)
    	if turno.nil?
    		RestaurantesReserva.select("hora_reserva").where("combinacion = ? and cancelado = ? and fecha_reserva = ? and hora_reserva > ? and hora_reserva < ?", idcombinacion, 0, fecha, hora_reserva, hora_nec)
    	else
    		RestaurantesReserva.select("hora_reserva").where("combinacion = ? and cancelado = ? and fecha_reserva = ? and hora_reserva > ? and hora_reserva < ? and turno = ?", idcombinacion, 0, fecha, hora_reserva, hora_nec, turno)
    	end
    end

    def self.getNumreservasmesacomb(combinacion, fecha, hora_reserva, turno = nil)
    	if turno.nil?
    		RestaurantesReserva.select("hora_reserva").where("mesa in (?) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>?", combinacion, 0, fecha, hora_reserva, hora_reserva)
    	else
    		RestaurantesReserva.select("hora_reserva").where("mesa in (?) and cancelado='?' and fecha_reserva=? and hora_reserva<=? and addtime(hora_reserva,tiempo)>? and turno = ?", combinacion, 0, fecha, hora_reserva, hora_reserva, turno)
    	end
    end

    def self.getNumreservasfuturasmesacomb(combinacion, fecha, hora_reserva, hora_nec, turno = nil)
    	if turno.nil?
    		RestaurantesReserva.select("hora_reserva").where("mesa in (?) and cancelado='?' and fecha_reserva=? and hora_reserva > ? and hora_reserva < ?", combinacion, 0, fecha, hora_reserva, hora_nec)
    	else
    		RestaurantesReserva.select("hora_reserva").where("mesa in (?) and cancelado='?' and fecha_reserva=? and hora_reserva > ? and hora_reserva < ? and turno = ?", combinacion, 0, fecha, hora_reserva, hora_nec, turno)
    	end
    end

end
