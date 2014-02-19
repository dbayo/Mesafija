class AsgTiposCocina < ActiveRecord::Base
    self.table_name = 'asg_tipos_cocina'
    self.primary_key = :idasg
    belongs_to :restaurante, :foreign_key => 'restaurante', :primary_key => 'idrestaurante', :class_name => 'Restaurante'
    belongs_to :tiposCocina, :foreign_key => 'tipococina', :primary_key => 'idtipococina', :class_name => 'TiposCocina'
end
