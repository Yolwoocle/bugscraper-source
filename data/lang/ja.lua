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
        large_mini_font = true,
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
        demo = "体験版", -- Chip added to the game logo to indicate that this version is a demo
        fps = "%d FPS",
        congratulations = "CONGRATULATIONS!",
        win_thanks = "デモをプレイしていただき、ありがとうございました。",
        win_wishlist = "ウィッシュリスト登録よろしくね(^_^)", -- "Wishlist" is a verb
        warning_web_controller = "一部のブラウザでは、コントローラーに対応していない場合があります。",

        combo = "%d コンボ", 
    },
    level = {
        world_prefix = "部署%s",

        -- Department names
        -- I chose to not use articles in english (so instead of "The Factory", it's just "Factory")

        -- Dept 1: This can be any vaguely office-y name (I just chose this in english because of the word play), 
        -- because this department just represents a generic office department.
        world_1 = "バグ資料室", 
        -- Dept 2: This department is a factory themed after bees, with grungy metallic environment
        world_2 = "工場",
        -- Dept 3: This is a moody, dark and mysterious room filled with endless racks of servers 
        world_3 = "サーバールーム",
        -- Dept 4: This is the highest department of the bugscraper, filled with lofty gardens and clean, white, modern architecture
        world_4 = "ガーデン",

        -- Dept 0: This is an underground secret department below the bugscraper. It contains a huge hangar with a large rocket. 
        world_0 = "地下室",
    },
    gun = {
        -- Gun names
        -- You can be more creative with these, you don't have to stay close to the originals.
        -- Look at google doc for image references
        machinegun = "ナッツガン",
        triple = "トリプルペッパー",
        burst = "バクカフン",--「爆風」Explosion+「花粉」Pollen / Previous proposal: ボムカフン
        shotgun = "ラズベリーショット",
        minigun = "タネガン",
        ring = "ビッグベリー",
        mushroom_cannon = "キノキャノン",

        resignation_letter = "退職届",
    },
    player = {
        name = {
            -- Player names
            -- If the native name clashes with something specific to the language/culture, please notify me.
            -- You can also use translitations into the language if needed (e.g. Mio -> ミオ)
            mio = "ミオ",
            cap = "キャップ",
            zia = "ジア",
            tok = "トック",
            nel = "ネル",
            nob = "ノブ",
            amb = "アンブ",

            -- These are guest characters from other games so please stay close to the original.
            rico = "リコ", -- From 'The Bullet Hopper'
            yv = "Y.V.", -- From 'Nuclear Throne' / See localized names here: https://docs.google.com/spreadsheets/d/18N1CNxIzSUm4CkIWUw0nbRnlxzAgoRbHpGyX8649Gjw/edit?usp=sharing
            leo = "レオ",
            dodu = "ドドゥー", 
        },
        abbreviation = "P%d", -- Short appreviation to denote players by their number. Example: in english, "P1" means "Player 1", in french "J1" means "Joueur 1".
    },
    enemy = {
        -- These are the boss names. Please look at the Gdocs for reference.
        -- Feel free to pick interesting names, and you don't have to base them off the english name.

        -- (for example, the french name for "Mr. Dung" is "J. De Bouse", which is a 
        -- play on words with the french word for 'dung' and a famous french humorist. 
        -- "The Webmaster" is a play on words between the theme of the area and spider webs)

        -- A somewhat witty and clownesque exectutive based off a Dung Beetle. 
        boss_1 = "フンコロ上司",--「フンコロガシ」Dung Beetle + 「上司」 Manager.
        --Previous proposal: "スカ・シッペー",--「スカラベ」scarab + 「すかしっぺ」 mean silent fart.

        -- The queen of the Factory, who's also a metal/rock singer.  
        boss_2 = "クイーン陛下", 

        -- The guardian of the Server Room, whose design is based off a motherboard and spiders.
        boss_3 = "ウェブマスター",

        -- A very large green cabbage-like, boulder-like, rolling enemy from the Garden area.   
        -- You're free to be more creative with this one. 
        -- (example: in French, I chose "Grobroco", "gros" (large) + "broco" (diminutive of broccoli))
        boss_4 = "ローリングキャベツ",--Cabegge Roll+ing

        -- The CEO of the company, and the final boss. Its name is somewhat ominous-sounding.
        -- Try to avoid ambiguity with the term "boss", which could be confused with the generic term for a video game boss.
        boss_5 = "CEO",
    },
    upgrade = {
        tea = {
            title = "緑茶",
            description = "追加❤ +%d",
        },
        espresso = {
            title = "エスプレッソ",
            description = "コンボ中 射撃速度がx%d上昇",
        },
        milk = {
            title = "ミルク",
            description = "最大❤ +%d増加",
        },
        boba = {
            title = "タピオカティー",
            description = "弾薬最大数 x%d増加",
        },
        soda = {
            title = "サイダー", -- As in Coca-cola/Pepsi style soda.
            description = "ジャンプ数 +%d追加",
        },
        fizzy_lemonade = {
            title = "炭酸レモネード",
            description = "ジャンプボタン長押しでグライド可能",
        },
        apple_juice = {
            title = "リンゴジュース",
            description = "❤ +%d回復",
        },
        hot_sauce = {
            title = "チリソース",
            description = "与ダメージ x%d / 弾薬消費量 x%d", -- First "%d" is the damage, second "%d" is ammo
        },
        coconut_water = {
            title = "ココナッツウォーター",
            description = "敵を踏みつけると 弾薬%d%%回復",
        },
        hot_chocolate = {
            title = "ホットチョコ",
            description = "装填速度が速くなる",
        },
        pomegranate_juice = {
            title = "ザクロジュース",
            description = "ダメージを受けると爆破が起きる",
        },
        energy_drink = {
            title = "エナドリ",
            description = "コンボメーターの減りが遅くなる",
        },
        gazpacho = {
            -- When you take damange, you have a 5-second window, where if you deal enough damage
            -- to enemies, you can recover 1 HP
            title = "ガスパチョ",
            description = "ダメージを受けた時 反撃できれば1❤回復",
        },
    },
    input = {
        prompts = {
            -- All of these are infinitive verbs and may be shown as button prompts 
            -- (i.e., "[X] Shoot", "[C] Jump", etc)

            -- Gameplay Actions
            move = "移動", 
            left = "左",
            right = "右",
            up = "上",
            down = "下",
            jump = "ジャンプ",
            shoot = "ショット",
            interact = "インタラクト",
            leave_game = "抜ける",
            open = "メニューを開く",         -- As in, "open menu", and NOT for, say, opening chests.
            collect = "拾う",   -- As in, "collect item", "collect gun", etc

            -- UI Actions
            ui_left = "左 (メニュー)",
            ui_right = "右 (メニュー)",
            ui_up = "上 (メニュー)",
            ui_down = "下 (メニュー)",
            ui_select = "決定",
            ui_back = "戻る",
            pause = "ポーズ",
            join = "参加", -- As, in joining the game, adding a new player to the game.
            -- As in, "Press [key] to split the keyboard". 
            -- Shown on the title screen when one keyboard player has joined. 
            -- Try to keep it as short as possible since space is limited there.
            split_keyboard = "キーボード分割", 

            wall_jump = "壁ジャンプ",
            jetpack = "ジェットパック", -- Refers to "jetpacking", a move in the game performed by shooting downwards with a gun.
        },
    },
    menu = {
        see_more = "もっと見る",
        yes = "はい",
        no = "いいえ",
        leave_menu = "メニューを閉じますか?", -- Generic "leave menu?"
        quit = {
            description = "本当に終了しますか?"
        },
        confirm_retry = {
            description = "リトライしますか?",
        },
        pause = {
            title = "ポーズ",
            resume = "再開",
            retry = "リトライ",

            -- This correspons to floor 0 in the game. To different cultures, the "ground floor" 
            -- might usually mean "floor 1", so please make sure to avoid ambiguity when translating. 
            -- (You can also translate as "main lobby" or something like it.)   
            return_to_ground_floor = "ロビーに戻る", 
            options = "設定",
            credits = "クレジット",
            feedback = "フィードバック",
            quit = "終了",
            website = "公式ウェブサイト",
            discord = "Discord",
            github = "GitHub",
        },
        options = {
            title = "設定",

            input = {
                title = "操作",
                input = "操作設定",
            },
            input_submenu = {
                title = "操作設定",
                reset_controls = "操作設定リセット",
                controller_button_style = "ボタンスタイル", -- The style of the buttons shown in-game. As in, PS4 style buttons, Xbox style buttons...
                controller_button_style_value = {
                    detect = "検出",
                    switch = "Switch",
                    playstation4 = "PlayStation 4",
                    playstation5 = "PlayStation 5",
                    xbox = "Xbox",
                },
                deadzone = "ジョイスティック感度",
                vibration = "振動",
                low_deadzone_warning = "感度が低すぎると 不具合を引き起こす場合があります", -- Warning displayed when the joystick deadzone is very small
                note_deadzone = "感度はメニューを閉じたときに適用されます",

                gameplay = "ゲームプレイ",
                interface = "UI",
                global = "一般",
                note_ui_min_button = "最低1つ設定してください",
                note_global_keyboard = "キーボード設定は全プレイヤー共有です",
                note_global_controller = "コントローラー設定は全プレイヤー共有です",
                -- Shown when navigating to player "%d"'s controller settings while no player of this number has joined yet.
                subtitle_no_player = "[⚠ 未参加 %d]", 
                -- Shown in the controller settings while no controller is connected
                subtitle_no_controller = "[⚠ コントローラー未接続]", 
                no_buttons = "[ボタン入力無し]",
                press_button = "[ボタンを押してください]", -- Try to keep it as short as possible
                -- When assigning buttons, if the user presses a button that is already bound, it will instead
                -- remove that button.
                press_again_to_remove = "割り当て済みのボタンを押すと、割り当てを解除できます", 
                
                keyboard = "キーボード",
                keyboard_solo = "キーボード (デフォルト)",
                -- "Split" as in, "the 1st split keyboard user"
                keyboard_p1 = "キーボード (操作 1)", 
                keyboard_p2 = "キーボード (操作 2)",

                controller = "コントローラー",
                controller_p1 = "コントローラー (プレイヤー 1)",
                controller_p2 = "コントローラー (プレイヤー 2)",
                controller_p3 = "コントローラー (プレイヤー 3)",
                controller_p4 = "コントローラー (プレイヤー 4)",
            },
            audio = {
                title = "オーディオ",
                sound = "サウンド", -- Toggle (on or off)
                volume = "音量", -- Slider (0% to 100%)
                sfx_volume = "SE音量", -- Slider (0% to 100%)
                music_volume = "BGM音量", -- Slider (0% to 100%)
                music_pause_menu = "ポーズメニュー中のBGM", -- Whether music should play on the pause menu
                ambience = "環境音",
            },
            visuals = {
                title = "ビジュアル",
                fullscreen = "フルスクリーン",
                pixel_scale = "ピクセル倍率", -- How big should every pixel be displayed on-screen (x1, x2, ...)
                pixel_scale_value = {
                    auto = "オート", -- Biggest number possible, whole or not
                    max_whole = "最大倍率", -- Biggest whole number possible
                },
                vsync = "Vシンク",
                menu_blur = "メニュー背景のぼかし", -- Whether to apply the blurring effect in menu backgrounds
                background_speed = "背景速度", -- How quickly the background scrolls 
                bullet_lightness = "弾丸の明るさ", -- How brightly bullets are rendered
            },
            game = {
                title = "ゲーム",
                tutorial = "チュートリアル",
                language = "言語",
                timer = "タイマー",
                mouse_visible = "マウスカーソル表示",
                pause_on_unfocus = "画面外時ポーズ", -- whether the game should pause when the window loses focus
                screenshake = "スクリーンの揺れ",
                skip_boss_intros = "ボスイントロ スキップ", -- Whether the game should skip the boss intro animations 
                show_fps_warning = "低フレームレート警告", -- Whether the game should show a warning when its framerate is low

            },
            language = {
                title = "言語",
            },
            confirm_language = {
                description = "ゲームを再起動して言語を適用しますか?",
            },
        },
        achievements = {
            title = "実績",
        },
        feedback = {
            title = "フィードバック",
            bugs = "バグ報告",
            features = "提案",
        },
        game_over = {
            title = "GAME OVER!",
            kills = "倒した敵の数",  -- The amount of enemies the player has killed
            deaths = "やられた回数",
            time = "タイム",             -- The time that the player took to complete the level
            floor = "階",           -- Which storey the player was on when they died
            score = "スコア",
            max_combo = "最大コンボ数",

            continue = "コンティニュー",
            quick_restart = "クイックリスタート",
        },
        stats = {
            title = "統計",

            time_total = "起動時間",
            time_ingame = "プレイ時間 (遊んだ分)",
            runs = "挑戦回数",
            best_run = "最高到達数", -- The biggest wave number reached on any run
        },
        new_reward = {
            new_skin = "新キャラ獲得!",
            new_upgrade = "新アップグレード獲得!",
        },
        win = {
            title = "CONGRATULATIONS!",
            wishlist = "ウィッシュリストに登録", -- "wishlist" is a verb
            continue = "コンティニュー",
        },
        joystick_removed = {
            title = "コントローラーが切断されました",
            description = "コントローラーを接続してください",
            continue = "このまま続ける",
            item = "プレイヤー%d (%s)", -- e.g. "Player 2 (Xbox Controller)"
        },
        credits = {
            title = "クレジット",
            ninesliced_presents = "Ninesliced presents",
            game_by = "A game by", 
            leo_bernard = "Léo Bernard", -- Please do not touch this
            music = "ミュージック",
            sound_design = "サウンドデザイン",
            localization = "ローカライズ",
            additional_art = "追加アート",
            playtesting = "プレイテスター",
            special_thanks = "スペシャルサンクス",
            trailer = "予告編",
            asset_creators = "アセット制作",
            tv_slideshow = "スライダーショー寄稿者", -- Refers to the powerpoint TV slideshow on the title screen, which was contributed by a variety of people 
            licenses = "アセット & ライブラリーライセンス",
            more = "その他多数の人達...",                        -- For the people that I might have forgotten in the special thanks section
            thank_you_for_playing = "Thank you for playing!", -- Shown at the end of the credits

            x_by_y = "%s by %s",                              -- "ASSET_NAME by CREATOR". Used to credit assets such as sound effects
            asset_item = "%s by %s / %s",                     -- "ASSET_NAME by CREATOR / LICENCE"
        },
        open_source = {
            title = "ソースライブラリーを開く",
        },
    },
    achievements = {
        ach_complete_w1 = {
            name = "バグ資料室",
            description = "部署1 突破",
        },
        ach_complete_w2 = {
            name = "工場",
            description = "部署2 突破",
        },
        ach_complete_w3 = {
            name = "サーバールーム",
            description = "部署3 突破",
        },
        ach_complete_w4 = {
            name = "ガーデン",
            description = "部署4 突破",
        },
        ach_complete_end = {
            name = "バケーション",
            description = "ミッション コンプリート",
        },
        ach_death = {
            name = "不屈の精神",
            description = "50回やられた",
        },
        ach_all_upgrades = {
            name = "猛烈なカクテル", --It was translated like this in Minecraft.
            description = "全てのアップグレードを解放した",
        },
        ach_all_skins = {
            name = "チームリーダー",
            description = "全てのキャラを解放した",
        },
        ach_max_hearts = {
            name = "恋人",
            description = "❤を7つ獲得した",
        },
        ach_no_damage_easy = {
            name = "アイアンバグ",
            description = "ノーダメージで20階突破した",
        },
        ach_no_damage_full = {
            name = "ゴールデンバグ",
            description = "ノーダメージで1ゲーム制覇した",
        },
        ach_no_floor = {
            name = "溶岩の床",
            description = "10階突破まで床に触れなかった",
        },
        ach_big_combo = {
            name = "バーサーカー",--I translated it as "berserker" to capture that feeling of bulldozing through everything with pure rage.
            description = "100コンボ達成",
        },
        ach_smash_easter_egg = {
            name = "GAME SET!", -- This is a reference to what the announcer says at the end of a match in Smash Bros.
            description = "秘密の出口の演出を見つけた", 
        },
    },
    discord = { -- Text used for Discord rich presence
        state = {
            solo = "ソロプレイ",
            local_multiplayer = "ローカルマルチプレイ",
        },
        details = {
            waiting = "ロビー",
            playing = "ゲーム中 (フロア %d/%d)",
            dying = "やられた (フロア %d/%d)",
            win = "勝利画面",
        },
    },
}
