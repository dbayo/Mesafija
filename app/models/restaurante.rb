class Restaurante < ActiveRecord::Base
    self.primary_key = :idrestaurante
    belongs_to :zona, :foreign_key => 'zona', :primary_key => 'idzona', :class_name => 'Zona'
    belongs_to :ciudad, :foreign_key => 'ciudad', :primary_key => 'idciudad', :class_name => 'Ciudade'
    has_many :restauranteOpiniones, :foreign_key => 'restaurante', :primary_key => 'idopinion', :class_name => 'RestaurantesOpinione'
    has_many :restauranteImg, :foreign_key => 'restaurante', :primary_key => 'idimg', :class_name => 'RestaurantesImg'
    has_many :asgTiposCocina
    has_many :tipoCocina, :through => :asgTiposCocina, :source => :tiposCocina
end
