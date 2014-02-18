class RestaurantesOpinione < ActiveRecord::Base
    self.primary_key = :idopinion
    belongs_to :restaurante

end
