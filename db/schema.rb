# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140217185352) do

  create_table "api_mesafijas", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asg_promos", primary_key: "idasg", force: true do |t|
    t.integer "partner", null: false
    t.integer "promo",   null: false
  end

  create_table "asg_tipos_cocina", primary_key: "idasg", force: true do |t|
    t.integer "restaurante", null: false
    t.integer "tipococina",  null: false
  end

  create_table "banners", primary_key: "idbanner", force: true do |t|
    t.integer "dc",                          default: 0, null: false
    t.integer "des",                         default: 0, null: false
    t.integer "lis",                         default: 0, null: false
    t.integer "orden",                       default: 0, null: false
    t.integer "activo",                      default: 0, null: false
    t.string  "memo"
    t.string  "tituloes"
    t.string  "tituloca"
    t.string  "tituloen"
    t.string  "titulofr"
    t.string  "titulode"
    t.string  "tituloit"
    t.string  "tituloru"
    t.string  "titulozh"
    t.text    "textoes",    limit: 16777215
    t.text    "textoca",    limit: 16777215
    t.text    "textoen",    limit: 16777215
    t.text    "textofr",    limit: 16777215
    t.text    "textode",    limit: 16777215
    t.text    "textoit",    limit: 16777215
    t.text    "textoru",    limit: 16777215
    t.text    "textozh",    limit: 16777215
    t.integer "selenlace",                   default: 0, null: false
    t.text    "enlace",     limit: 16777215
    t.text    "enlacees",   limit: 16777215
    t.text    "enlaceca",   limit: 16777215
    t.text    "enlaceen",   limit: 16777215
    t.text    "enlacefr",   limit: 16777215
    t.text    "enlacede",   limit: 16777215
    t.text    "enlaceit",   limit: 16777215
    t.text    "enlaceru",   limit: 16777215
    t.text    "enlacezh",   limit: 16777215
    t.integer "selarchivo",                  default: 0, null: false
    t.string  "archivo"
    t.string  "archivoes"
    t.string  "archivoca"
    t.string  "archivoen"
    t.string  "archivofr"
    t.string  "archivode"
    t.string  "archivoit"
    t.string  "archivoru"
    t.string  "archivozh"
    t.string  "rollover"
    t.string  "rolloveres"
    t.string  "rolloverca"
    t.string  "rolloveren"
    t.string  "rolloverfr"
    t.string  "rolloverde"
    t.string  "rolloverit"
    t.string  "rolloverru"
    t.string  "rolloverzh"
  end

  create_table "ciudades", primary_key: "idciudad", force: true do |t|
    t.integer "visible",      default: 0, null: false
    t.string  "ciudad"
    t.integer "departamento", default: 0, null: false
  end

  create_table "config", primary_key: "idconfig", force: true do |t|
    t.string  "flgcliente",      default: ""
    t.string  "flgwebcliente",   default: ""
    t.string  "flgmailcliente",  default: ""
    t.integer "flges",           default: 0,  null: false
    t.integer "flgca",           default: 0,  null: false
    t.integer "flgen",           default: 0,  null: false
    t.integer "flgfr",           default: 0,  null: false
    t.integer "flgde",           default: 0,  null: false
    t.integer "flgit",           default: 0,  null: false
    t.integer "flgru",           default: 0,  null: false
    t.integer "flgzh",           default: 0,  null: false
    t.integer "flgsuscriptores", default: 0,  null: false
    t.integer "flgecommerce",    default: 0,  null: false
    t.integer "flgecratio",      default: 0,  null: false
    t.integer "flgectrprov",     default: 0,  null: false
    t.integer "flgectrpais",     default: 0,  null: false
    t.integer "flgecpm",         default: 0,  null: false
    t.integer "flgecgg",         default: 0,  null: false
  end

  create_table "departamentos", primary_key: "iddepartamento", force: true do |t|
    t.string "departamento"
  end

  create_table "descargas", primary_key: "iddescarga", force: true do |t|
    t.integer "dc",         default: 0, null: false
    t.integer "des",        default: 0, null: false
    t.integer "lis",        default: 0, null: false
    t.integer "orden",      default: 0, null: false
    t.integer "activo",     default: 0, null: false
    t.string  "tituloes"
    t.string  "tituloca"
    t.string  "tituloen"
    t.string  "titulofr"
    t.string  "titulode"
    t.string  "tituloit"
    t.string  "tituloru"
    t.string  "titulozh"
    t.integer "selarchivo", default: 0, null: false
    t.string  "archivo"
    t.string  "archivoes"
    t.string  "archivoca"
    t.string  "archivoen"
    t.string  "archivofr"
    t.string  "archivode"
    t.string  "archivoit"
    t.string  "archivoru"
    t.string  "archivozh"
  end

  create_table "grupos_facturacion", primary_key: "idgrupo", force: true do |t|
    t.integer "orden",  default: 0, null: false
    t.string  "nombre"
    t.integer "min",    default: 0, null: false
    t.integer "max",    default: 0, null: false
    t.integer "precio", default: 0, null: false
  end

  create_table "iconos", primary_key: "idicono", force: true do |t|
    t.integer "dc",      default: 0, null: false
    t.integer "cat",     default: 0, null: false
    t.integer "lis",     default: 0, null: false
    t.string  "archivo"
  end

  create_table "media", primary_key: "idmedia", force: true do |t|
    t.integer "dc",                         default: 0, null: false
    t.integer "des",                        default: 0, null: false
    t.integer "lis",                        default: 0, null: false
    t.integer "orden",                      default: 0, null: false
    t.integer "activo",                     default: 0, null: false
    t.string  "tituloes"
    t.string  "tituloca"
    t.string  "tituloen"
    t.string  "titulofr"
    t.string  "titulode"
    t.string  "tituloit"
    t.string  "tituloru"
    t.string  "titulozh"
    t.text    "textoes",   limit: 16777215
    t.text    "textoca",   limit: 16777215
    t.text    "textoen",   limit: 16777215
    t.text    "textofr",   limit: 16777215
    t.text    "textode",   limit: 16777215
    t.text    "textoit",   limit: 16777215
    t.text    "textoru",   limit: 16777215
    t.text    "textozh",   limit: 16777215
    t.integer "selenlace",                  default: 0, null: false
    t.text    "enlace",    limit: 16777215
    t.text    "enlacees",  limit: 16777215
    t.text    "enlaceca",  limit: 16777215
    t.text    "enlaceen",  limit: 16777215
    t.text    "enlacefr",  limit: 16777215
    t.text    "enlacede",  limit: 16777215
    t.text    "enlaceit",  limit: 16777215
    t.text    "enlaceru",  limit: 16777215
    t.text    "enlacezh",  limit: 16777215
    t.string  "archivo"
  end

  create_table "medios", primary_key: "idmedio", force: true do |t|
    t.integer "borrado", default: 0, null: false
    t.integer "orden",   default: 0, null: false
    t.integer "visible", default: 0, null: false
    t.string  "medio"
  end

  create_table "ns_suscriptores", primary_key: "idsuscriptor", force: true do |t|
    t.string "email"
    t.string "ciudad", default: ""
    t.date   "fecha",               null: false
  end

  add_index "ns_suscriptores", ["email"], name: "idx_email", unique: true, using: :btree

  create_table "partners", primary_key: "idpartner", force: true do |t|
    t.integer "borrado", default: 0, null: false
    t.integer "visible", default: 0, null: false
    t.string  "partner"
    t.string  "cabweb"
    t.string  "pieweb"
    t.string  "cabmail"
  end

  create_table "rangos_precio", primary_key: "idrangoprecio", force: true do |t|
    t.integer "orden",       default: 0, null: false
    t.integer "visible",     default: 0, null: false
    t.string  "rangoprecio"
  end

  create_table "restaurantes", primary_key: "idrestaurante", force: true do |t|
    t.integer "visible",                          default: 0,                     null: false
    t.date    "fecha_alta",                                                       null: false
    t.integer "listaespera",                      default: 0,                     null: false
    t.integer "modoreservas",                     default: 0,                     null: false
    t.integer "nuevo",                            default: 0,                     null: false
    t.integer "ordenpromo",                       default: 0,                     null: false
    t.integer "destacado",                        default: 0,                     null: false
    t.integer "gestorreservas",                   default: 0,                     null: false
    t.integer "infoenv",                          default: 0,                     null: false
    t.string  "nombre"
    t.text    "direccion",       limit: 16777215
    t.string  "cp",              limit: 5
    t.integer "zona",                             default: 0,                     null: false
    t.integer "ciudad",                           default: 0,                     null: false
    t.string  "telefono",        limit: 15
    t.string  "celular",         limit: 15
    t.string  "email"
    t.string  "email2"
    t.string  "contrasenya"
    t.string  "accesoreservas"
    t.string  "contrasenyares"
    t.float   "lat",             limit: 10,                                       null: false
    t.float   "lng",             limit: 10,                                       null: false
    t.string  "empresa"
    t.string  "nit"
    t.text    "fdireccion",      limit: 16777215
    t.string  "fcp",             limit: 5
    t.string  "fciudad"
    t.string  "fpais"
    t.string  "ccc"
    t.string  "cnombre"
    t.string  "ccargo"
    t.string  "ctelefono",       limit: 15
    t.string  "cemail"
    t.string  "web"
    t.string  "facebook"
    t.string  "twitter"
    t.text    "txtpresentacion", limit: 16777215
    t.text    "txtotros",        limit: 16777215
    t.integer "rangoprecio",                      default: 0,                     null: false
    t.time    "margen_reserva",                   default: '2000-01-01 00:00:00', null: false
    t.integer "bloqueo_dia",                      default: 0,                     null: false
    t.integer "break_l",                          default: 0,                     null: false
    t.integer "break_m",                          default: 0,                     null: false
    t.integer "break_x",                          default: 0,                     null: false
    t.integer "break_j",                          default: 0,                     null: false
    t.integer "break_v",                          default: 0,                     null: false
    t.integer "break_s",                          default: 0,                     null: false
    t.integer "break_d",                          default: 0,                     null: false
    t.integer "almuerzo_l",                       default: 0,                     null: false
    t.integer "almuerzo_m",                       default: 0,                     null: false
    t.integer "almuerzo_x",                       default: 0,                     null: false
    t.integer "almuerzo_j",                       default: 0,                     null: false
    t.integer "almuerzo_v",                       default: 0,                     null: false
    t.integer "almuerzo_s",                       default: 0,                     null: false
    t.integer "almuerzo_d",                       default: 0,                     null: false
    t.integer "onces_l",                          default: 0,                     null: false
    t.integer "onces_m",                          default: 0,                     null: false
    t.integer "onces_x",                          default: 0,                     null: false
    t.integer "onces_j",                          default: 0,                     null: false
    t.integer "onces_v",                          default: 0,                     null: false
    t.integer "onces_s",                          default: 0,                     null: false
    t.integer "onces_d",                          default: 0,                     null: false
    t.integer "cena_l",                           default: 0,                     null: false
    t.integer "cena_m",                           default: 0,                     null: false
    t.integer "cena_x",                           default: 0,                     null: false
    t.integer "cena_j",                           default: 0,                     null: false
    t.integer "cena_v",                           default: 0,                     null: false
    t.integer "cena_s",                           default: 0,                     null: false
    t.integer "cena_d",                           default: 0,                     null: false
    t.time    "break_l_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_l_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_m_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_m_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_x_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_x_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_j_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_j_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_v_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_v_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_s_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_s_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_d_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "break_d_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_l_a",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_l_c",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_m_a",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_m_c",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_x_a",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_x_c",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_j_a",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_j_c",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_v_a",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_v_c",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_s_a",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_s_c",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_d_a",                     default: '2000-01-01 00:00:00', null: false
    t.time    "almuerzo_d_c",                     default: '2000-01-01 00:00:00', null: false
    t.time    "onces_l_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_l_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_m_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_m_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_x_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_x_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_j_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_j_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_v_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_v_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_s_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_s_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_d_a",                        default: '2000-01-01 00:00:00', null: false
    t.time    "onces_d_c",                        default: '2000-01-01 00:00:00', null: false
    t.time    "cena_l_a",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_l_c",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_m_a",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_m_c",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_x_a",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_x_c",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_j_a",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_j_c",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_v_a",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_v_c",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_s_a",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_s_c",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_d_a",                         default: '2000-01-01 00:00:00', null: false
    t.time    "cena_d_c",                         default: '2000-01-01 00:00:00', null: false
  end

  add_index "restaurantes", ["ciudad"], name: "idx_ciudad", using: :btree
  add_index "restaurantes", ["destacado"], name: "idx_destacado", using: :btree
  add_index "restaurantes", ["nuevo"], name: "idx_nuevo", using: :btree
  add_index "restaurantes", ["rangoprecio"], name: "idx_rangoprecio", using: :btree
  add_index "restaurantes", ["visible"], name: "idx_visible", using: :btree
  add_index "restaurantes", ["zona"], name: "idx_zona", using: :btree

  create_table "restaurantes_bloqueos", primary_key: "id_bloqueo", force: true do |t|
    t.integer "restaurante", default: 0,                     null: false
    t.date    "fecha",                                       null: false
    t.time    "hora",        default: '2000-01-01 00:00:00', null: false
    t.integer "mesa",        default: 0,                     null: false
    t.integer "combinacion", default: 0,                     null: false
  end

  create_table "restaurantes_combinaciones", primary_key: "idcombinacion", force: true do |t|
    t.integer "salon",       default: 0, null: false
    t.string  "combinacion"
    t.integer "plazas",      default: 0, null: false
    t.integer "plazas_min",  default: 0, null: false
    t.integer "plazas_max",  default: 0, null: false
    t.integer "mesafija",    default: 0, null: false
  end

  add_index "restaurantes_combinaciones", ["salon"], name: "idx_salon", using: :btree

  create_table "restaurantes_favoritos", primary_key: "idfavorito", force: true do |t|
    t.integer "usuario",     default: 0, null: false
    t.integer "restaurante", default: 0, null: false
  end

  add_index "restaurantes_favoritos", ["usuario"], name: "idx_restaurante", using: :btree

  create_table "restaurantes_img", primary_key: "idimg", force: true do |t|
    t.integer "restaurante", default: 0, null: false
    t.integer "orden",       default: 0, null: false
    t.integer "activo",      default: 0, null: false
    t.string  "archivo"
    t.string  "pie"
  end

  add_index "restaurantes_img", ["restaurante"], name: "idx_restaurante", using: :btree

  create_table "restaurantes_mesas", primary_key: "idmesa", force: true do |t|
    t.integer "salon",      default: 0, null: false
    t.string  "nombre"
    t.integer "plazas",     default: 0, null: false
    t.integer "plazas_min", default: 0, null: false
    t.integer "plazas_max", default: 0, null: false
    t.integer "mesafija",   default: 0, null: false
  end

  add_index "restaurantes_mesas", ["salon"], name: "idx_salon", using: :btree

  create_table "restaurantes_opiniones", primary_key: "idopinion", force: true do |t|
    t.integer "restaurante",                    default: 0, null: false
    t.integer "usuario",                        default: 0, null: false
    t.integer "reserva",                        default: 0, null: false
    t.date    "fecha",                                      null: false
    t.integer "favorito",                       default: 0, null: false
    t.integer "cocina",                         default: 0, null: false
    t.integer "ambiente",                       default: 0, null: false
    t.integer "calidadprecio",                  default: 0, null: false
    t.integer "servicio",                       default: 0, null: false
    t.integer "limpieza",                       default: 0, null: false
    t.text    "comentario",    limit: 16777215
  end

  add_index "restaurantes_opiniones", ["restaurante"], name: "idx_restaurante", using: :btree

  create_table "restaurantes_plazas", primary_key: "idfecha", force: true do |t|
    t.integer "restaurante", default: 0, null: false
    t.date    "fecha",                   null: false
    t.integer "break",       default: 0, null: false
    t.integer "almuerzo",    default: 0, null: false
    t.integer "onces",       default: 0, null: false
    t.integer "cena",        default: 0, null: false
  end

  add_index "restaurantes_plazas", ["fecha"], name: "idx_fecha", using: :btree
  add_index "restaurantes_plazas", ["restaurante"], name: "idx_restaurante", using: :btree

  create_table "restaurantes_promos", primary_key: "idpromo", force: true do |t|
    t.integer "restaurante",                                  null: false
    t.integer "orden",                            default: 0, null: false
    t.integer "visible",                          default: 0, null: false
    t.integer "borrado",                          default: 0, null: false
    t.integer "mesafija",                         default: 1, null: false
    t.integer "widget",                           default: 0, null: false
    t.string  "nombre"
    t.text    "descripcion",     limit: 16777215
    t.string  "img"
    t.integer "break_l",                          default: 1, null: false
    t.integer "break_m",                          default: 1, null: false
    t.integer "break_x",                          default: 1, null: false
    t.integer "break_j",                          default: 1, null: false
    t.integer "break_v",                          default: 1, null: false
    t.integer "break_s",                          default: 1, null: false
    t.integer "break_d",                          default: 1, null: false
    t.integer "almuerzo_l",                       default: 1, null: false
    t.integer "almuerzo_m",                       default: 1, null: false
    t.integer "almuerzo_x",                       default: 1, null: false
    t.integer "almuerzo_j",                       default: 1, null: false
    t.integer "almuerzo_v",                       default: 1, null: false
    t.integer "almuerzo_s",                       default: 1, null: false
    t.integer "almuerzo_d",                       default: 1, null: false
    t.integer "onces_l",                          default: 1, null: false
    t.integer "onces_m",                          default: 1, null: false
    t.integer "onces_x",                          default: 1, null: false
    t.integer "onces_j",                          default: 1, null: false
    t.integer "onces_v",                          default: 1, null: false
    t.integer "onces_s",                          default: 1, null: false
    t.integer "onces_d",                          default: 1, null: false
    t.integer "cena_l",                           default: 1, null: false
    t.integer "cena_m",                           default: 1, null: false
    t.integer "cena_x",                           default: 1, null: false
    t.integer "cena_j",                           default: 1, null: false
    t.integer "cena_v",                           default: 1, null: false
    t.integer "cena_s",                           default: 1, null: false
    t.integer "cena_d",                           default: 1, null: false
    t.date    "fechainicio",                                  null: false
    t.date    "fechafin",                                     null: false
    t.integer "promociones_max",                  default: 0, null: false
    t.integer "comensales_min",                   default: 0, null: false
    t.integer "comensales_max",                   default: 0, null: false
  end

  add_index "restaurantes_promos", ["restaurante"], name: "idx_restaurante", using: :btree

  create_table "restaurantes_reg", primary_key: "idreg", force: true do |t|
    t.string  "email"
    t.string  "clave", default: "", null: false
    t.integer "tipo",  default: 0,  null: false
  end

  create_table "restaurantes_reservas", primary_key: "id_reserva", force: true do |t|
    t.integer "restaurante",                    default: 0,                     null: false
    t.integer "usuario",                        default: 0,                     null: false
    t.integer "comentado",                      default: 0,                     null: false
    t.integer "cancelado",                      default: 0,                     null: false
    t.integer "lespera",                        default: 0,                     null: false
    t.integer "consumo",                        default: 0,                     null: false
    t.integer "widget",                         default: 0,                     null: false
    t.integer "partner",                        default: 0,                     null: false
    t.date    "fecha_alta",                                                     null: false
    t.time    "hora_alta",                      default: '2000-01-01 00:00:00', null: false
    t.date    "fecha_reserva",                                                  null: false
    t.time    "hora_reserva",                   default: '2000-01-01 00:00:00', null: false
    t.integer "comensales",                     default: 0,                     null: false
    t.integer "tipo_reserva",                   default: 0,                     null: false
    t.integer "promocion",                      default: 0,                     null: false
    t.integer "mesa",                           default: 0,                     null: false
    t.integer "combinacion",                    default: 0,                     null: false
    t.time    "tiempo",                         default: '2000-01-01 00:00:00', null: false
    t.text    "observaciones", limit: 16777215
    t.string  "turno",         limit: 10,       default: "",                    null: false
  end

  add_index "restaurantes_reservas", ["cancelado"], name: "idx_cancelado", using: :btree
  add_index "restaurantes_reservas", ["combinacion"], name: "idx_combinacion", using: :btree
  add_index "restaurantes_reservas", ["fecha_reserva"], name: "idx_fechareserva", using: :btree
  add_index "restaurantes_reservas", ["hora_reserva"], name: "idx_hora", using: :btree
  add_index "restaurantes_reservas", ["mesa"], name: "idx_mesa", using: :btree
  add_index "restaurantes_reservas", ["restaurante"], name: "idx_restaurante", using: :btree

  create_table "restaurantes_salones", primary_key: "idsalon", force: true do |t|
    t.integer "restaurante", default: 0, null: false
    t.integer "visible",     default: 0, null: false
    t.string  "nombre"
  end

  add_index "restaurantes_salones", ["restaurante"], name: "idx_restaurante", using: :btree

  create_table "restaurantes_tiempos", force: true do |t|
    t.integer "restaurante",   default: 0,                     null: false
    t.time    "tiempo_1",      default: '2000-01-01 00:00:00', null: false
    t.time    "tiempo_2",      default: '2000-01-01 00:00:00', null: false
    t.time    "tiempo_3",      default: '2000-01-01 00:00:00', null: false
    t.time    "tiempo_4",      default: '2000-01-01 00:00:00', null: false
    t.time    "tiempo_5",      default: '2000-01-01 00:00:00', null: false
    t.time    "tiempo_6",      default: '2000-01-01 00:00:00', null: false
    t.time    "tiempo_7",      default: '2000-01-01 00:00:00', null: false
    t.time    "tiempo_8",      default: '2000-01-01 00:00:00', null: false
    t.time    "tiempo_9",      default: '2000-01-01 00:00:00', null: false
    t.time    "tiempo_10",     default: '2000-01-01 00:00:00', null: false
    t.time    "tiempo_grupos", default: '2000-01-01 00:00:00', null: false
  end

  add_index "restaurantes_tiempos", ["restaurante"], name: "idx_restaurante", using: :btree

  create_table "restaurantes_usuarios", primary_key: "id_usuario", force: true do |t|
    t.integer "visible",                      default: 1,                     null: false
    t.integer "restaurante",                  default: 0,                     null: false
    t.date    "fecha",                                                        null: false
    t.time    "hora",                         default: '2000-01-01 00:00:00', null: false
    t.string  "nombre"
    t.string  "apellidos"
    t.string  "empresa"
    t.string  "cargo"
    t.string  "cedula",      limit: 25
    t.string  "telefono",    limit: 15
    t.string  "ciudad"
    t.integer "medio",                        default: 0,                     null: false
    t.string  "email"
    t.string  "password"
    t.text    "nota",        limit: 16777215,                                 null: false
  end

  add_index "restaurantes_usuarios", ["email"], name: "idx_email", using: :btree
  add_index "restaurantes_usuarios", ["restaurante"], name: "idx_restaurante", using: :btree
  add_index "restaurantes_usuarios", ["telefono"], name: "idx_telefono", using: :btree

  create_table "restaurantes_usuarios_reg", primary_key: "idreg", force: true do |t|
    t.string "email"
    t.string "clave", default: "", null: false
  end

  create_table "secciones", primary_key: "idseccion", force: true do |t|
    t.integer "orden",                    default: 0, null: false
    t.integer "activo",                   default: 0, null: false
    t.string  "tipo",          limit: 20
    t.string  "memo"
    t.string  "menu"
    t.integer "flgsecec",                 default: 0, null: false
    t.integer "flgcategorias",            default: 0, null: false
    t.integer "flgtitulos",               default: 0, null: false
    t.integer "flgtextos",                default: 0, null: false
    t.integer "flgtextosalt",             default: 0, null: false
    t.integer "flgyoutube",               default: 0, null: false
    t.integer "flgvimeo",                 default: 0, null: false
    t.integer "flggeo",                   default: 0, null: false
    t.integer "flgprecio",                default: 0, null: false
    t.integer "flgprecioalt",             default: 0, null: false
    t.integer "flgstock",                 default: 0, null: false
    t.integer "flgico",                   default: 0, null: false
    t.integer "flgicocat",                default: 0, null: false
    t.integer "flgimagenes",              default: 0, null: false
    t.integer "flgdescargas",             default: 0, null: false
    t.integer "flgbanners",               default: 0, null: false
    t.integer "flgasc",                   default: 0, null: false
    t.integer "flgicowmax",               default: 0, null: false
    t.integer "flgicohmax",               default: 0, null: false
    t.integer "flgicocatwmax",            default: 0, null: false
    t.integer "flgicocathmax",            default: 0, null: false
    t.integer "flgimgnmax",               default: 0, null: false
    t.integer "flgimgwmax",               default: 0, null: false
    t.integer "flgimghmax",               default: 0, null: false
    t.integer "flgimgtit",                default: 0, null: false
    t.integer "flgimgtxt",                default: 0, null: false
    t.integer "flgimglink",               default: 0, null: false
    t.integer "flgdesnmax",               default: 0, null: false
    t.integer "flgbannmax",               default: 0, null: false
    t.integer "flgbanwmax",               default: 0, null: false
    t.integer "flgbanhmax",               default: 0, null: false
    t.integer "flgbantit",                default: 0, null: false
    t.integer "flgbantxt",                default: 0, null: false
    t.integer "flgbanlink",               default: 0, null: false
    t.integer "flgbanroll",               default: 0, null: false
    t.integer "flgascnmax",               default: 0, null: false
  end

  create_table "secciones_desc", primary_key: "iddescriptiva", force: true do |t|
    t.integer "dc",                            default: 0, null: false
    t.integer "seccion",                       default: 0, null: false
    t.integer "orden",                         default: 0, null: false
    t.string  "memo"
    t.string  "menu"
    t.integer "flgtitulos",                    default: 0, null: false
    t.integer "flgtextos",                     default: 0, null: false
    t.integer "flgtextosalt",                  default: 0, null: false
    t.integer "flgyoutube",                    default: 0, null: false
    t.integer "flgvimeo",                      default: 0, null: false
    t.integer "flggeo",                        default: 0, null: false
    t.integer "flgimagenes",                   default: 0, null: false
    t.integer "flgdescargas",                  default: 0, null: false
    t.integer "flgbanners",                    default: 0, null: false
    t.integer "flgasc",                        default: 0, null: false
    t.integer "flgimgnmax",                    default: 0, null: false
    t.integer "flgimgwmax",                    default: 0, null: false
    t.integer "flgimghmax",                    default: 0, null: false
    t.integer "flgimgtit",                     default: 0, null: false
    t.integer "flgimgtxt",                     default: 0, null: false
    t.integer "flgimglink",                    default: 0, null: false
    t.integer "flgdesnmax",                    default: 0, null: false
    t.integer "flgbannmax",                    default: 0, null: false
    t.integer "flgbanwmax",                    default: 0, null: false
    t.integer "flgbanhmax",                    default: 0, null: false
    t.integer "flgbantit",                     default: 0, null: false
    t.integer "flgbantxt",                     default: 0, null: false
    t.integer "flgbanlink",                    default: 0, null: false
    t.integer "flgbanroll",                    default: 0, null: false
    t.integer "flgascnmax",                    default: 0, null: false
    t.string  "tituloes"
    t.string  "tituloca"
    t.string  "tituloen"
    t.string  "titulofr"
    t.string  "titulode"
    t.string  "tituloit"
    t.string  "tituloru"
    t.string  "titulozh"
    t.text    "textoes",      limit: 16777215
    t.text    "textoca",      limit: 16777215
    t.text    "textoen",      limit: 16777215
    t.text    "textofr",      limit: 16777215
    t.text    "textode",      limit: 16777215
    t.text    "textoit",      limit: 16777215
    t.text    "textoru",      limit: 16777215
    t.text    "textozh",      limit: 16777215
    t.text    "textoaltes",   limit: 16777215
    t.text    "textoaltca",   limit: 16777215
    t.text    "textoalten",   limit: 16777215
    t.text    "textoaltfr",   limit: 16777215
    t.text    "textoaltde",   limit: 16777215
    t.text    "textoaltit",   limit: 16777215
    t.text    "textoaltru",   limit: 16777215
    t.text    "textoaltzh",   limit: 16777215
    t.text    "youtube",      limit: 16777215
    t.text    "vimeo",        limit: 16777215
  end

  create_table "secciones_list", primary_key: "idlistado", force: true do |t|
    t.integer "dc",                                                  default: 0,   null: false
    t.integer "seccion",                                             default: 0,   null: false
    t.integer "categoria",                                           default: 0,   null: false
    t.date    "fecha",                                                             null: false
    t.integer "orden",                                               default: 0,   null: false
    t.integer "activo",                                              default: 0,   null: false
    t.string  "tituloes"
    t.string  "tituloca"
    t.string  "tituloen"
    t.string  "titulofr"
    t.string  "titulode"
    t.string  "tituloit"
    t.string  "tituloru"
    t.string  "titulozh"
    t.text    "textoes",    limit: 16777215
    t.text    "textoca",    limit: 16777215
    t.text    "textoen",    limit: 16777215
    t.text    "textofr",    limit: 16777215
    t.text    "textode",    limit: 16777215
    t.text    "textoit",    limit: 16777215
    t.text    "textoru",    limit: 16777215
    t.text    "textozh",    limit: 16777215
    t.text    "textoaltes", limit: 16777215
    t.text    "textoaltca", limit: 16777215
    t.text    "textoalten", limit: 16777215
    t.text    "textoaltfr", limit: 16777215
    t.text    "textoaltde", limit: 16777215
    t.text    "textoaltit", limit: 16777215
    t.text    "textoaltru", limit: 16777215
    t.text    "textoaltzh", limit: 16777215
    t.text    "youtube",    limit: 16777215
    t.text    "vimeo",      limit: 16777215
    t.decimal "precio",                      precision: 8, scale: 2, default: 0.0, null: false
    t.decimal "precioalt",                   precision: 8, scale: 2, default: 0.0, null: false
    t.integer "ratio",                                               default: 0,   null: false
    t.integer "stock",                                               default: 0,   null: false
  end

  create_table "secciones_list_cat", primary_key: "idcategoria", force: true do |t|
    t.integer "dc",          default: 0, null: false
    t.integer "seccion",     default: 0, null: false
    t.integer "categoria",   default: 0, null: false
    t.integer "contenido",   default: 0, null: false
    t.integer "orden",       default: 0, null: false
    t.integer "activo",      default: 0, null: false
    t.string  "categoriaes"
    t.string  "categoriaca"
    t.string  "categoriaen"
    t.string  "categoriafr"
    t.string  "categoriade"
    t.string  "categoriait"
    t.string  "categoriaru"
    t.string  "categoriazh"
  end

  create_table "tipos_cocina", primary_key: "idtipococina", force: true do |t|
    t.integer "orden",      default: 0, null: false
    t.integer "visible",                null: false
    t.string  "tipococina"
  end

  create_table "usuarios", id: false, force: true do |t|
    t.integer "id",       null: false
    t.string  "email"
    t.string  "password"
  end

  add_index "usuarios", ["email"], name: "usuario", unique: true, using: :btree
  add_index "usuarios", ["id"], name: "id", using: :btree

  create_table "usuarios_reg", primary_key: "idreg", force: true do |t|
    t.string "email"
    t.string "clave", default: "", null: false
  end

  create_table "zonas", primary_key: "idzona", force: true do |t|
    t.integer "visible", default: 0, null: false
    t.string  "zona"
    t.integer "ciudad",  default: 0, null: false
  end

end
