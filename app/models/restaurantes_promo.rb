class RestaurantesPromo < ActiveRecord::Base
    self.primary_key = :idpromo
    belongs_to :restaurante, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'Restaurante'

    def getDisponibilidad
    	{
    		:lunes => (!self.break_l.zero? || !self.almuerzo_l.zero? || !self.onces_l.zero? || !self.cena_l.zero?),
    		:martes => (!self.break_m.zero? || !self.almuerzo_m.zero? || !self.onces_m.zero? || !self.cena_m.zero?),
    		:miercoles => (!self.break_x.zero? || !self.almuerzo_x.zero? || !self.onces_x.zero? || !self.cena_x.zero?),
    		:jueves => (!self.break_j.zero? || !self.almuerzo_j.zero? || !self.onces_j.zero? || !self.cena_j.zero?),
    		:viernes => (!self.break_v.zero? || !self.almuerzo_v.zero? || !self.onces_v.zero? || !self.cena_v.zero?),
    		:sabado => (!self.break_s.zero? || !self.almuerzo_s.zero? || !self.onces_s.zero? || !self.cena_s.zero?),
    		:domingo => (!self.break_d.zero? || !self.almuerzo_d.zero? || !self.onces_d.zero? || !self.cena_d.zero?)
    	}
    end

    def getUrlImg
    	(self.img.blank?) ? "" : "http://www.mesafija.com/restaurantes_img/"+self.img
    end
end
