class RestaurantesBloqueo < ActiveRecord::Base

    self.primary_key = :id_bloqueo

    def self.getNumbloqueoscomb(idcombinacion, fecha, hora)
    	RestaurantesBloqueo.select("hora").where(:combinacion => idcombinacion, :fecha => fecha, :hora => hora)
    end

    def self.getNumbloqueosfuturoscomb(idcombinacion, fecha, hora, hora_nec)
    	RestaurantesBloqueo.select("hora").where("combinacion = ? and fecha = ? and hora>? and hora < ?", idcombinacion, fecha, hora, hora_nec)
    end
    
    def self.getNumbloqueosmesacomb(combinacion, fecha, hora)
    	RestaurantesBloqueo.select("hora").where("mesa in (?) and fecha=? and hora=?", combinacion, fecha, hora)
    end

    def self.getNumbloqueosfuturosmesacomb(combinacion, fecha, hora, hora_nec)
    	RestaurantesBloqueo.select("hora").where("mesa in (?) and fecha=? and hora>? and hora<?", combinacion, fecha, hora, hora_nec)
    end

end
