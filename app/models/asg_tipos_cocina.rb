class AsgTiposCocina < ActiveRecord::Base
    self.table_name = 'asg_tipos_cocina'
    self.primary_key = :idasg
    belongs_to :restaurante
    belongs_to :tipo_cocina
end
