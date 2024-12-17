
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
    local gameFonts = "assets/fonts/New Athletic M54.ttf"
    bg1 = display.newImageRect(sceneGroup,"assets/sprites/BackdropMain.png", display.actualContentWidth * 2,
    display.actualContentHeight)
    bg1.x = display.contentCenterX
    bg1.y = display.contentCenterY

    local jetpackTitle = display.newText(sceneGroup, "Jetpack", 225, 110, gameFonts,50 );
    local pogrideTitle = display.newText(sceneGroup, "Pogride", 225, 155, gameFonts,40 );
    pogrideTitle:setFillColor(1, 0.647, 0)

    local btnPlay = display.newImageRect(sceneGroup, "assets/sprites/ButtonPlayGame.png", 234, 63)
    btnPlay.x = 222
    btnPlay.y = 225

    local function gotoGame(event)
        if event.phase == "ended" then
            composer.gotoScene("game", { effect = "slideDown", time = 800 })
        end
    end
    
    btnPlay:addEventListener("touch", gotoGame)

    local creditTitle = display.newText(sceneGroup, "create by aji mustofa @pepega90", 50, 295, native.systemFontBold, 20)
    creditTitle:setFillColor(0,0,0)
	-- Code here runs when the scene is first created but has not yet appeared on screen


end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
        -- Runtime:addEventListener("mouse", onMouse)

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
