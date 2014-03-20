class RestaurantesImg < ActiveRecord::Base
    self.table_name = 'restaurantes_img'
    self.primary_key = :idimg

    def getUrlImg
    	(self.archivo.blank?) ? "" : "http://www.mesafija.com/restaurantes_img/"+self.archivo
    end
end
