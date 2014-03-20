module Auxiliar
  extend ActiveSupport::Concern

  def tags_string
    tags.map(&:name).join(', ')
  end
end