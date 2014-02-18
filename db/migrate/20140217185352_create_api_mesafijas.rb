class CreateApiMesafijas < ActiveRecord::Migration
  def change
    create_table :api_mesafijas do |t|

      t.timestamps
    end
  end
end
