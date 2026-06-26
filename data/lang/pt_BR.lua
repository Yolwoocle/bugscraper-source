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
        menu_padding = 0.18,
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
        congratulations = "PARABÉNS!",
        win_thanks = "Obrigado por jogar o demo",
        win_wishlist = "Adicione o jogo à lista de desejos :)", -- "Wishlist" is a verb
        warning_web_controller = "Alguns navegadores podem não funcionar com controles",

        combo = "COMBO %d", 
    },
    level = {
        world_prefix = "Departamento %s",

        -- Department names
        -- I chose to not use articles in english (so instead of "The Factory", it's just "Factory")

        -- Dept 1: This can be any vaguely office-y name (I just chose this in english because of the word play), 
        -- because this department just represents a generic office department.
        world_1 = "Recursos Insetos", 
        -- Dept 2: This department is a factory themed after bees, with grungy metallic environment
        world_2 = "Fábrica",
        -- Dept 3: This is a moody, dark and mysterious room filled with endless racks of servers 
        world_3 = "Sala de Servidor",
        -- Dept 4: This is the highest department of the bugscraper, filled with lofty gardens and clean, white, modern architecture
        world_4 = "Jardins",

        -- Dept 0: This is an underground secret department below the bugscraper. It contains a huge hangar with a large rocket. 
        world_0 = "Porão",
    },
    gun = {
        -- Gun names
        -- You can be more creative with these, you don't have to stay close to the originals.
        -- Look at google doc for image references
        machinegun = "Atirador de Ervilha",
        triple = "Triplimenta",
        burst = "Explosão de Pólen",
        shotgun = "Lança-Amora",
        minigun = "Metralhadora de Semente",
        ring = "Amorona",
        mushroom_cannon = "Canhão de Cogumelo",

        resignation_letter = "Carta de Demissão",
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
            yv = "Y.V.", -- From 'Nuclear Throne' / See localized names here: https://docs.google.com/spreadsheets/d/18N1CNxIzSUm4CkIWUw0nbRnlxzAgoRbHpGyX8649Gjw/edit?usp=sharing
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
        boss_1 = "Sr. Esterco",

        -- The queen of the Factory, who's also a metal/rock singer.  
        boss_2 = "Vossa Majestade", 

        -- The guardian of the Server Room, whose design is based off a motherboard and spiders.
        boss_3 = "Webmaster",

        -- A very large green cabbage-like, boulder-like, rolling enemy from the Garden area.   
        -- You're free to be more creative with this one. 
        -- (example: in French, I chose "Grobroco", "gros" (large) + "broco" (diminutive of broccoli))
        boss_4 = "Repolhossus",

        -- The CEO of the company, and the final boss. Its name is somewhat ominous-sounding.
        -- Try to avoid ambiguity with the term "boss", which could be confused with the generic term for a video game boss.
        boss_5 = "Diretor",
    },
    upgrade = {
        tea = {
            title = "Chá Verde",
            description = "+%d ❤ extra",
        },
        espresso = {
            title = "Expresso",
            description = "x%d velocidade de tiro durante um combo",
        },
        milk = {
            title = "Leite",
            description = "+%d ❤ máximo",
        },
        boba = {
            title = "Bubble Tea",
            description = "x%d capacidade de munição",
        },
        soda = {
            title = "Refri", -- As in Coca-cola/Pepsi style soda.
            description = "+%d pulos no ar",
        },
        fizzy_lemonade = {
            title = "Limonada Suíça",
            description = "Aperte pulo para planar",
        },
        apple_juice = {
            title = "Suco de Maçã",
            description = "Recupera +%d ❤",
        },
        hot_sauce = {
            title = "Molho de Pimenta",
            description = "Dá x%d de dano usando x%d balas", -- First "%d" is the damage, second "%d" is ammo
        },
        coconut_water = {
            title = "Água de Coco",
            description = "Pule nos inimigos para recuperar %d%% de munição",
        },
        hot_chocolate = {
            title = "Chocolate Quente",
            description = "Velocidade de recarga mais rápida",
        },
        pomegranate_juice = {
            title = "Suco de Romã",
            description = "Tomar dano cria uma explosão",
        },
        energy_drink = {
            title = "Energético",
            description = "Contador de combo diminui mais lentamente",
        },
        gazpacho = {
            -- When you take damange, you have a 5-second window, where if you deal enough damage
            -- to enemies, you can recover 1 HP
            title = "Gaspacho",
            description = "Depois de sofrer dano, revide rapidamente para ganhar 1 ❤",
        },
    },
    input = {
        prompts = {
            -- All of these are infinitive verbs and may be shown as button prompts 
            -- (i.e., "[X] Shoot", "[C] Jump", etc)

            -- Gameplay Actions
            move = "Mover", 
            left = "Esquerda",
            right = "Direita",
            up = "Cima",
            down = "Baixo",
            jump = "Pular",
            shoot = "Atirar",
            interact = "Interagir",
            leave_game = "Sair",
            open = "Abrir",         -- As in, "open menu", and NOT for, say, opening chests.
            collect = "Pegar",   -- As in, "collect item", "collect gun", etc

            -- UI Actions
            ui_left = "Esquerda (menu)",
            ui_right = "Direita (menu)",
            ui_up = "Cima (menu)",
            ui_down = "Baixo (menu)",
            ui_select = "Confirmar",
            ui_back = "Voltar",
            pause = "Pausar",
            join = "Entrar", -- As, in joining the game, adding a new player to the game.
            -- As in, "Press [key] to split the keyboard". 
            -- Shown on the title screen when one keyboard player has joined. 
            -- Try to keep it as short as possible since space is limited there.
            split_keyboard = "Dividir teclado", 

            wall_jump = "Pular da parede",
            jetpack = "Usar jetpack", -- Refers to "jetpacking", a move in the game performed by shooting downwards with a gun.
        },
    },
    menu = {
        see_more = "ver mais...",
        yes = "SIM",
        no = "NÃO",
        leave_menu = "Sair do menu?", -- Generic "leave menu?"
        quit = {
            description = "Tem certeza que quer sair?"
        },
        confirm_retry = {
            description = "Tentar de novo?",
        },
        pause = {
            title = "PAUSA",
            resume = "RETOMAR",
            retry = "TENTAR DE NOVO",

            -- This correspons to floor 0 in the game. To different cultures, the "ground floor" 
            -- might usually mean "floor 1", so please make sure to avoid ambiguity when translating. 
            -- (You can also translate as "main lobby" or something like it.)   
            return_to_ground_floor = "VOLTAR PARA O TÉRREO", 
            options = "OPÇÕES",
            credits = "CRÉDITOS",
            feedback = "COMENTÁRIOS",
            quit = "SAIR",
            website = "SITE OFICIAL",
            discord = "DISCORD",
            github = "GITHUB",
        },
        options = {
            title = "OPÇÕES",

            input = {
                title = "Controles",
                input = "CONFIGURAÇÃO DOS CONTROLES...",
            },
            input_submenu = {
                title = "CONFIGURAÇÃO DOS CONTROLES",
                reset_controls = "RESETAR CONTROLES",
                controller_button_style = "ESTILO DOS BOTÕES", -- The style of the buttons shown in-game. As in, PS4 style buttons, Xbox style buttons...
                controller_button_style_value = {
                    detect = "detectar",
                    switch = "Switch",
                    playstation4 = "PlayStation 4",
                    playstation5 = "PlayStation 5",
                    xbox = "Xbox",
                },
                deadzone = "DEADZONE DO JOYSTICK",
                vibration = "VIBRAÇÃO",
                low_deadzone_warning = "Valores baixos podem dar problema", -- Warning displayed when the joystick deadzone is very small
                note_deadzone = "Opções de deadzone vão ser aplicadas após sair desse menu",

                gameplay = "Gameplay",
                interface = "Menus",
                global = "Global",
                note_ui_min_button = "É necessário pelo menos 1 botão",
                note_global_keyboard = "Esses botões são iguais para todos os jogadores com teclado",
                note_global_controller = "Esses botões são iguais para todos os controles",
                -- Shown when navigating to player "%d"'s controller settings while no player of this number has joined yet.
                subtitle_no_player = "[⚠ SEM JOGADOR %d]", 
                -- Shown in the controller settings while no controller is connected
                subtitle_no_controller = "[⚠ SEM CONTROLE CONECTADO]", 
                no_buttons = "[SEM BOTÕES]",
                press_button = "[APERTE O BOTÃO]", -- Try to keep it as short as possible
                -- When assigning buttons, if the user presses a button that is already bound, it will instead
                -- remove that button.
                press_again_to_remove = "Aperte um botão já vinculado para remover", 
                
                keyboard = "Teclado",
                keyboard_solo = "TECLADO (Padrão)",
                -- "Split" as in, "the 1st split keyboard user"
                keyboard_p1 = "TECLADO (Parte 1)", 
                keyboard_p2 = "TECLADO (Parte 2)",

                controller = "CONTROLE",
                controller_p1 = "CONTROLE (Jogador 1)",
                controller_p2 = "CONTROLE (Jogador 2)",
                controller_p3 = "CONTROLE (Jogador 3)",
                controller_p4 = "CONTROLE (Jogador 4)",
            },
            audio = {
                title = "Audio",
                sound = "SOM", -- Toggle (on or off)
                volume = "VOLUME", -- Slider (0% to 100%)
                sfx_volume = "VOLUME DE EFEITOS SONOROS", -- Slider (0% to 100%)
                music_volume = "VOLUME DA MÚSICA", -- Slider (0% to 100%)
                music_pause_menu = "MÚSICA NO MENU DE PAUSA", -- Whether music should play on the pause menu
                ambience = "SONS DE AMBIENTE",
            },
            visuals = {
                title = "Visuais",
                fullscreen = "TELA CHEIA",
                pixel_scale = "ESCALA DE PIXEL", -- How big should every pixel be displayed on-screen (x1, x2, ...)
                pixel_scale_value = {
                    auto = "auto", -- Biggest number possible, whole or not
                    max_whole = "máximo inteiro", -- Biggest whole number possible
                },
                vsync = "VSYNC (SINCRONIZAÇÃO VERTICAL)",
                menu_blur = "DESFOQUE DO FUNDO DO MENU", -- Whether to apply the blurring effect in menu backgrounds
                background_speed = "VELOCIDADE DO FUNDO", -- How quickly the background scrolls 
                bullet_lightness = "BRILHO DOS PROJÉTEIS", -- How brightly bullets are rendered
            },
            game = {
                title = "Jogo",
                tutorial = "TUTORIAL...",
                language = "IDIOMA...",
                timer = "CRONÔMETRO",
                mouse_visible = "MOSTRAR PONTEIRO DO MOUSE",
                pause_on_unfocus = "PAUSAR QUANDO SEM FOCO", -- whether the game should pause when the window loses focus
                screenshake = "VIBRAÇÃO DA TELA",
                skip_boss_intros = "PULAR INTRO DOS CHEFÕES", -- Whether the game should skip the boss intro animations 
                show_fps_warning = "MOSTRAR AVISO DE FPS BAIXO", -- Whether the game should show a warning when its framerate is low

            },
            language = {
                title = "IDIOMA",
            },
            confirm_language = {
                description = "Reiniciar o jogo para aplicar o idioma?",
            },
        },
        achievements = {
            title = "CONQUISTAS",
        },
        feedback = {
            title = "COMENTÁRIOS",
            bugs = "DENUNCIAR ERRO",
            features = "SUGERIR UMA FUNCIONALIDADE",
        },
        game_over = {
            title = "GAME OVER!",
            kills = "Inimigos abatidos", -- The amount of enemies the player has killed
            deaths = "Mortes",
            time = "Tempo",            -- The time that the player took to complete the level
            floor = "Andar",          -- Which storey the player was on when they died
            score = "Pontuação",
            max_combo = "Combo Máximo",

            continue = "CONTINUAR",
            quick_restart = "RESTART RÁPIDO",
        },
        stats = {
            title = "ESTATÍSTICAS",

            time_total = "Tempo de Jogo (total)",
            time_ingame = "Tepo de Jogo (ativo)",
            runs = "Rounds",
            best_run = "Maior onda enfrentada", -- The biggest wave number reached on any run
        },
        new_reward = {
            new_skin = "Novo personagem!",
            new_upgrade = "Novo upgrade!",
        },
        win = {
            title = "PARABÉNS!",
            wishlist = "ADICIONE À LISTA DE DESEJOS NA STEAM", -- "wishlist" is a verb
            continue = "CONTINUAR",
        },
        joystick_removed = {
            title = "CONTROLE DISCONECTADO",
            description = "Favor conectar os seguintes controles:",
            continue = "CONTINUAR MESMO ASSIM",
            item = "Jogador %d (%s)", -- e.g. "Player 2 (Xbox Controller)"
        },
        credits = {
            title = "CRÉDITOS",
            ninesliced_presents = "Ninesliced apresenta",
            game_by = "Um jogo por", 
            leo_bernard = "Léo Bernard", -- Please do not touch this
            music = "Música",
            sound_design = "Sound design",
            localization = "Localização",
            additional_art = "Arte adicional",
            playtesting = "Playtest",
            special_thanks = "Agradecimentos especiais",
            trailer = "Trailer",
            asset_creators = "Criadores de recursos",
            tv_slideshow = "Contribuentes aos slides", -- Refers to the powerpoint TV slideshow on the title screen, which was contributed by a variety of people 
            licenses = "Licenças de bibliotecas e recursos",
            more = "E vários outros...",                        -- For the people that I might have forgotten in the special thanks section
            thank_you_for_playing = "Obrigado por jogar!", -- Shown at the end of the credits

            x_by_y = "%s por %s",                              -- "ASSET_NAME by CREATOR". Used to credit assets such as sound effects
            asset_item = "%s por %s / %s",                     -- "ASSET_NAME by CREATOR / LICENCE"
        },
        open_source = {
            title = "Bibliotecas open source",
        },
    },
    achievements = {
        ach_complete_w1 = {
            name = "Recursos Insetos",
            description = "Complete o Departamento 1",
        },
        ach_complete_w2 = {
            name = "Fábrica",
            description = "Complete o Departamento 2",
        },
        ach_complete_w3 = {
            name = "Sala de Servidor",
            description = "Complete o Departamento 3",
        },
        ach_complete_w4 = {
            name = "Jardins",
            description = "Complete o Departamento 4",
        },
        ach_complete_end = {
            name = "Férias",
            description = "Complete o jogo",
        },
        ach_death = {
            name = "Perseverança",
            description = "Morra 50 vezes",
        },
        ach_all_upgrades = {
            name = "Um Coquetel Furioso",
            description = "Desbloqueie todas as melhorias",
        },
        ach_all_skins = {
            name = "Líder da Equipe",
            description = "Desbloqueie todos os personagens",
        },
        ach_max_hearts = {
            name = "Cheio de Amor",
            description = "Obtenha 7 ❤",
        },
        ach_no_damage_easy = {
            name = "Besouro de Ferro",
            description = "Complete 20 andares sem receber dano",
        },
        ach_no_damage_full = {
            name = "Besouro de Ouro",
            description = "Complete uma run sem receber dano",
        },
        ach_no_floor = {
            name = "O Chão é Lava",
            description = "Percorra 10 andares sem tocar no chão",
        },
        ach_big_combo = {
            name = "Furioso",
            description = "Consiga um combo de 100",
        },
        ach_smash_easter_egg = {
            name = "GAME!", -- This is a reference to what the announcer says at the end of a match in Smash Bros.
            description = "Obtenha a animação secreta", 
        },
    },
    discord = { -- Text used for Discord rich presence
        state = {
            solo = "Jogando solo",
            local_multiplayer = "Multiplayer local",
        },
        details = {
            waiting = "No lobby",
            playing = "Em jogo (andar %d/%d)",
            dying = "Derrotado(a) (andar %d/%d)",
            win = "Tela de vitória",
        },
    },
}
