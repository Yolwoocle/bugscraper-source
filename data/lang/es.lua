--[[
    TO TRANSLATORS:
    * Reference document for all enemies, players, levels, etc: (can be outdated)
      https://docs.google.com/document/d/13UntpWqoTXgYnBm5HL0pZmjBDwMStIN8YB1IPdi7hlA
    * To search for added or changed strings, you can use this regex in the search functionality
      of your text editor: (Ctrl+F then Alt+R on VS Code)
      \[\[((ADDED)|(REMOVED))
    * It is very easy for me to add more glyphs if needed, just tell me and I'll do it.
    * Please notify me if there are any special technical requirements. (e.g. text rendering specifics, etc)
]]

return {
    __meta = {
        -- Do not touch this section.
        menu_padding = 0.15,
        large_mini_font = false,
    },
    language = {
        -- These should be kept untranslated in their original language ("English", "Français", "简体中文", etc)
        en = "English",
        es = "Español",
        fr = "Français",
        pl = "Polski",
        pt_BR = "Português Brasileiro",
        zh_Hans = "简体中文",
        ja = "日本語",
    },
    game = {
        demo = "DEMO", -- Chip added to the game logo to indicate that this version is a demo
        fps = "%d FPS",
        congratulations = "FELICITACIONES!",
        win_thanks = "Gracias por jugar esta demo",
        win_wishlist = "Agregalo a tu lista de deseados en Steam :)", -- "Wishlist" is a verb
        warning_web_controller = "Algunos navegadores no tienen el soporte de mandos necesario",

        combo = "%d COMBO",
    },
    level = {
        world_prefix = "Departmento %s",

        -- Department names
        -- I chose to not use articles in english (so instead of "The Factory", it's just "Factory")

        -- Dept 1: This can be any vaguely office-y name (I just chose this in english because of the word play),
        -- because this department just represents a generic office department.
        world_1 = "Recursos de Depuracionces",
        -- Dept 2: This department is a factory themed after bees, with grungy metallic environment
        world_2 = "Fábrica",
        -- Dept 3: This is a moody, dark and mysterious room filled with endless racks of servers
        world_3 = "Servidores",
        -- Dept 4: This is the highest department of the bugscraper, filled with lofty gardens and clean, white, modern architecture
        world_4 = "Jardines",

        -- Dept 0: This is an underground secret department below the bugscraper. It contains a huge hangar with a large rocket.
        world_0 = "Sótano",
    },
    gun = {
        -- Gun names
        -- You can be more creative with these, you don't have to stay close to the originals.
        -- Look at google doc for image references
        machinegun = "Pistola de guisantes",
        triple = "Pimienta triple",
        burst = "Golpe de polen",
        shotgun = "Escopeta de frambuesa",
        minigun = "Ametralladora de semillas",
        ring = "Baya grande",
        mushroom_cannon = "Cañón de champiñones",

        resignation_letter = "Carta de renuncia",
    },
    player = {
        name = {
            -- Player names
            -- If the native name clashes with something specific to the language/culture, please notify me.
            -- You can also use translitations into the language if needed (e.g. Mio -> ミオ)
            mio = "Mio",
            cap = "Cap",
            zia = "Zia",
            tok = "Tok",
            nel = "Nel",
            nob = "Nob",
            amb = "Amb",

            -- These are guest characters from other games so please stay close to the original.
            rico = "Rico", -- From 'The Bullet Hopper'
            yv = "Y.V.",   -- From 'Nuclear Throne' / See localized names here: https://docs.google.com/spreadsheets/d/18N1CNxIzSUm4CkIWUw0nbRnlxzAgoRbHpGyX8649Gjw/edit?usp=sharing
            leo = "Leo",
            dodu = "Dodu",
        },
        abbreviation = "J%d", -- Short appreviation to denote players by their number. Example: in english, "P1" means "Player 1", in french "J1" means "Joueur 1".
    },
    enemy = {
        -- These are the boss names. Please look at the Gdocs for reference.
        -- Feel free to pick interesting names, and you don't have to base them off the english name.

        -- (for example, the french name for "Mr. Dung" is "J. De Bouse", which is a
        -- play on words with the french word for 'dung' and a famous french humorist.
        -- "The Webmaster" is a play on words between the theme of the area and spider webs)

        -- A somewhat witty and clownesque exectutive based off a Dung Beetle.
        boss_1 = "Sr. Estiércol",

        -- The queen of the Factory, who's also a metal/rock singer.
        boss_2 = "Su majestad",

        -- The guardian of the Server Room, whose design is based off a motherboard and spiders.
        boss_3 = "El maestro de redes",

        -- A very large green cabbage-like, boulder-like, rolling enemy from the Garden area.
        -- You're free to be more creative with this one.
        -- (example: in French, I chose "Grobroco", "gros" (large) + "broco" (diminutive of broccoli))
        boss_4 = "Coloso Rodadoso",

        -- The CEO of the company, and the final boss. Its name is somewhat ominous-sounding.
        -- Try to avoid ambiguity with the term "boss", which could be confused with the generic term for a video game boss.
        boss_5 = "El Jefazo",
    },
    upgrade = {
        tea = {
            title = "Té verde",
            description = "+%d ❤ extra",
        },
        espresso = {
            title = "Espresso",
            description =
            "x%d de Velocidad de disparo mientras estás en un combo",
        },
        milk = {
            title = "Leche",
            description = "+%d ❤ permanente",
        },
        boba = {
            title = "Té de Boba",
            description = "Multiplica x%d el maximo de munición",
        },
        soda = {
            title = "Gaseosa", -- As in Coca-cola/Pepsi style soda.
            description = "+%d salto en el aire",
        },
        fizzy_lemonade = {
            title = "Limonada efervescente",
            description = "Mantén saltar para bajar suavemente",
        },
        apple_juice = {
            title = "Jugo de manzana",
            description = "Recupera +%d ❤",
        },
        hot_sauce = {
            title = "Salsa picante",
            description = "Hace x%d daño pero usa x%d munición", -- First "%d" is the damage, second "%d" is ammo
        },
        coconut_water = {
            title = "Agua de coco",
            description = "Pisar enemigos te da de vuelta %d%% munición",
        },
        hot_chocolate = {
            title = "Chocolate caliente",
            description = "x%d Velocidad de recarga",
        },
        pomegranate_juice = {
            title = "Jugo de granada",
            description = "Crea una explosión cuando recibes daño",
        },
        energy_drink = {
            title = "Bebida Energizante",
            description = "El medidor del combo baja más lento",
        },
        gazpacho = {
            title = "Gazpacho",
            description = "Después de recibir daño, pelea de regreso rapidamente para recuperar 1 ❤",
        },
    },
    input = {
        prompts = {
            -- All of these are infinitive verbs and may be shown as button prompts
            -- (i.e., "[X] Shoot", "[C] Jump", etc)

            -- Gameplay Actions
            move = "Mover",
            left = "Izquierda",
            right = "Derecha",
            up = "Arriba",
            down = "Abajo",
            jump = "Saltar",
            shoot = "Disparar",
            interact = "Interactuar",
            leave_game = "Salir",
            open = "Abrir",         -- As in, "open menu", and NOT for, say, opening chests.
            collect = "Recolectar", -- As in, "collect item", "collect gun", etc

            -- UI Actions
            ui_left = "Izquierda (menu)",
            ui_right = "Derecha (menu)",
            ui_up = "Arriba (menu)",
            ui_down = "Abajo (menu)",
            ui_select = "Confirmar",
            ui_back = "Atrás",
            pause = "Pausar",
            join = "Unirse", -- As, in joining the game, adding a new player to the game.
            -- As in, "Press [key] to split the keyboard".
            -- Shown on the title screen when one keyboard player has joined.
            -- Try to keep it as short as possible since space is limited there.
            split_keyboard = "Compartir teclado",

            wall_jump = "Salto de pared",
            jetpack = "Jetpack", -- Refers to "jetpacking", a move in the game performed by shooting downwards with a gun.
        },
    },
    menu = {
        see_more = "ver maś...",
        yes = "SÍ",
        no = "NO",
        leave_menu = "¿Salir del menú?", -- Generic "leave menu?"
        quit = {
            description = "¿Seguro que quieres salir?"
        },
        confirm_retry = {
            description = "Reintentar?",
        },
        pause = {
            title = "PAUSAR",
            resume = "CONTINUAR",
            retry = "REINTENTAR",

            -- This correspons to floor 0 in the game. To different cultures, the "ground floor"
            -- might usually mean "floor 1", so please make sure to avoid ambiguity when translating.
            -- (You can also translate as "main lobby" or something like it.)
            return_to_ground_floor = "VOLVER AL PRIMER PISO",
            options = "OPCIONES",
            credits = "CRÉDITOS",
            feedback = "COMENTARIOS",
            quit = "SALIR",
            website = "SITIO OFICIAL",
            discord = "DISCORD",
            github = "GITHUB",
        },
        options = {
            title = "OPCIONES",

            input = {
                title = "Entrada",
                input = "CONFIGURACIÓN DE ENTRADA...",
            },
            input_submenu = {
                title = "CONFIGURACIÓN DE ENTRADA",
                reset_controls = "REINICIAR CONTROLES",
                controller_button_style = "ESTILO DE BOTONES", -- The style of the buttons shown in-game. As in, PS4 style buttons, Xbox style buttons...
                controller_button_style_value = {
                    detect = "detectar",
                    switch = "Switch",
                    playstation4 = "PlayStation 4",
                    playstation5 = "PlayStation 5",
                    xbox = "Xbox",
                },
                deadzone = "ZONA MUERTA DE LA PALANCA",
                vibration = "VIBRACIÓN",
                low_deadzone_warning = "Tolerancias de zona muerta baja pueden causar problemas", -- Warning displayed when the joystick deadzone is very small
                note_deadzone = "Ajustes de zona muerta tomarán efecto al salir de este menu",

                gameplay = "Jugabilidad",
                interface = "Interfaz",
                global = "Global",
                note_ui_min_button = "Al menos una configuración es requerida",
                note_global_keyboard = "Estas configuraciones son las mismas para todos los jugadores de teclado",
                note_global_controller = "Estas configuraciones son las mismas para todos los controladores",
                -- Shown when navigating to player "%d"'s controller settings while no player of this number has joined yet.
                subtitle_no_player = "[⚠ NO HAY JUGADOR %d]",
                -- Shown in the controller settings while no controller is connected
                subtitle_no_controller = "[⚠ NO HAY MANDO CONECTADO]",
                no_buttons = "[NO HAY BOTÓN]",
                press_button = "[PRESIONE BOTÓN]", -- Try to keep it as short as possible
                -- When assigning buttons, if the user presses a button that is already bound, it will instead
                -- remove that button.
                press_again_to_remove = "Presione una tecla ya vinculada para removerla",

                keyboard = "Teclado",
                keyboard_solo = "TECLADO (Por defecto)",
                -- "Split" as in, "the 1st split keyboard user"
                keyboard_p1 = "TECLADO (Mitad 1)",
                keyboard_p2 = "TECLADO (Mitad 2)",

                controller = "MANDO",
                controller_p1 = "MANDO (Jugador 1)",
                controller_p2 = "MANDO (Jugador 2)",
                controller_p3 = "MANDO (Jugador 3)",
                controller_p4 = "MANDO (Jugador 4)",
            },
            audio = {
                title = "Audio",
                sound = "SONIDO",                                                -- Toggle (on or off)
                volume = "VOLUMEN",                                              -- Slider (0% to 100%)
                sfx_volume = "VOLUMEN DE LOS EFECTOS DE SONIDO",                 -- Slider (0% to 100%)
                music_volume = "VOLUMEN DE LA MÚSICA",                           -- Slider (0% to 100%)
                music_pause_menu = "REPRODUCIR MÚSICA DURANTE EL MENU DE PAUSA", -- Whether music should play on the pause menu
                ambience = "SONIDOS AMBIENTALES",
            },
            visuals = {
                title = "Gráficos",
                fullscreen = "PANTALLA COMPLETA",
                pixel_scale = "ESCALA DE LOS PIXELES", -- How big should every pixel be displayed on-screen (x1, x2, ...)
                pixel_scale_value = {
                    auto = "automática",               -- Biggest number possible, whole or not
                    max_whole = "máximo entero",       -- Biggest whole number possible
                },
                vsync = "VSYNC",
                menu_blur = "DIFUMINAR FONDO DEL MENU",   -- Whether to apply the blurring effect in menu backgrounds
                background_speed = "VELOCIDAD DEL FONDO", -- How quickly the background scrolls
                bullet_lightness = "BRILLO DE BALAS",     -- How brightly bullets are rendered
            },
            game = {
                title = "Juego",
                tutorial = "TUTORIAL...",
                language = "IDIOMA...",
                timer = "TEMPORIZADOR DE PARTIDA",
                mouse_visible = "MOSTRAR PUNTERO DEL RATÓN",
                pause_on_unfocus = "PAUSAR AL PERDER EL FOCO",     -- whether the game should pause when the window loses focus
                screenshake = "SACUDIDO DE PATALLA",
                skip_boss_intros = "OMITIR INTRODUCCIÓN DE JEFES", -- Whether the game should skip the boss intro animations
                show_fps_warning = "AVISAR DE BAJO RENDIMIENTO",   -- Whether the game should show a warning when its framerate is low

            },
            language = {
                title = "IDIOMA",
            },
            confirm_language = {
                description = "¿Desea reiniciar el juego para aplicar el nuevo idioma?",
            },
        },
        achievements = {
            title = "LOGROS",
        },
        feedback = {
            title = "COMENTARIOS",
            bugs = "REPORTAR UN PROBLEMA",
            features = "PROPONER UNA IDEA",
        },
        game_over = {
            title = "JUEGO TERMINADO!",
            kills = "Enemigos matados",   -- The amount of enemies the player has killed
            deaths = "Muertes",
            time = "Tiempo transcurrido", -- The time that the player took to complete the level
            floor = "Piso",               -- Which storey the player was on when they died
            score = "Puntaje",
            max_combo = "Combo Máximo",

            continue = "CONTINUAR",
            quick_restart = "REINICIO RÁPIDO",
        },
        stats = {
            title = "ESTADÍSTICAS",

            time_total = "Tiempo jugado (total)",
            time_ingame = "Tiempo jugado (en juego)",
            runs = "Rondas",
            best_run = "Oleada más alta", -- The biggest wave number reached on any run
        },
        new_reward = {
            new_skin = "Nuevo Carácter!",
            new_upgrade = "Nueva Mejora!",
        },
        win = {
            title = "FELICITACIONES!",
            wishlist = "AGREGALO A TU LISTA DE DESEADOS EN STEAM", -- "wishlist" is a verb
            continue = "CONTINUAR",
        },
        joystick_removed = {
            title = "MANDO DESCONECTADO",
            description = "Por favor conecte los siguientes mandos:",
            continue = "CONTINUAR DE TODAS FORMAS",
            item = "Jugador %d (%s)", -- e.g. "Player 2 (Xbox Controller)"
        },
        credits = {
            title = "CREDITOS",
            ninesliced_presents = "Ninesliced presenta",
            game_by = "Un juego por",
            leo_bernard = "Léo Bernard", -- Please do not touch this
            music = "Musica",
            sound_design = "Diseño auditivo",
            localization = "Localización",
            additional_art = "Arte adicional",
            playtesting = "Probadores de Jugabilidad",
            special_thanks = "Agradecimentos especiales",
            trailer = "Trailer",
            asset_creators = "Creadores de recursos",
            tv_slideshow = "Contribuciones de la presentación en la TV", -- Refers to the powerpoint TV slideshow on the title screen, which was contributed by a variety of people
            licenses = "Recursos y Lisencias de librerías",
            more = "Y muchos más...",                                    -- For the people that I might have forgotten in the special thanks section
            thank_you_for_playing = "¡Gracias por jugar!",               -- Shown at the end of the credits

            x_by_y = "%s por %s",                                        -- "ASSET_NAME by CREATOR". Used to credit assets such as sound effects
            asset_item = "%s por %s / %s",                               -- "ASSET_NAME by CREATOR / LICENCE"
        },
        open_source = {
            title = "Licencias de código abierto",
        },
    },
    achievements = {
        ach_complete_w1 = {
            name = "Recursos de Depuracionces",
            description = "Completa el Departmento 1",
        },
        ach_complete_w2 = {
            name = "Fábrica",
            description = "Completa el Departmento 2",
        },
        ach_complete_w3 = {
            name = "Servidores",
            description = "Completa el Departmento 3",
        },
        ach_complete_w4 = {
            name = "Jardines",
            description = "Completa el Departmento 4",
        },
        ach_complete_end = {
            name = "Vacaciones",
            description = "Completa el juego",
        },
        ach_death = {
            name = "Perseverancia",
            description = "Muere 50 veces",
        },
        ach_all_upgrades = {
            name = "Coctél furioso",
            description = "Desbloquea todos las mejoras",
        },
        ach_all_skins = {
            name = "Líder del equipo",
            description = "Desbloquea todos los personajes",
        },
        ach_max_hearts = {
            name = "Amante",
            description = "Obtén 7 ❤",
        },
        ach_no_damage_easy = {
            name = "Bicho de acero",
            description = "No te dejes lastimar por 20 pisos",
        },
        ach_no_damage_full = {
            name = "Bicho de oro",
            description = "No te dejes lastimar por un juego completo",
        },
        ach_no_floor = {
            name = "El piso es lava",
            description = "No toques el piso por 10 pisos",
        },
        ach_big_combo = {
            name = "Furioso",
            description = "Obtén un combo de 100",
        },
        ach_smash_easter_egg = {
            name = "SE ACABO!", -- This is a reference to what the announcer says at the end of a match in Smash Bros.
            description = "Obtén la animación secreta de salida",
        },
    },
    discord = { -- Text used for Discord rich presence
        state = {
            solo = "Jugando solo",
            local_multiplayer = "Multijugador local",
        },
        details = {
            waiting = "En el vestíbulo",
            playing = "Jugando (Piso %d/%d)",
            dying = "Derrotado (Piso %d/%d)",
            win = "Pantalla de victoria",
        },
    },
}
