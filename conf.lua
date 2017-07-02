function love.conf(game)
    game.window.title = "Untitled"
    game.window.icon  = nil -- Filepath to an image to use as the window's icon (string)

    game.modules.audio    = false
    game.modules.joystick = false
    game.modules.math     = false
    game.modules.physics  = false
    game.modules.sound    = false
    game.modules.touch    = false
    game.modules.video    = false
end