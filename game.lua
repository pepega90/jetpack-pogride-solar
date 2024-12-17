
local composer = require( "composer" )

local scene = composer.newScene()

local physics = require("physics")
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
physics.start()
physics.setGravity(0, 20)

local isHolding = false
local gameOver = false
local gameFonts = "assets/fonts/New Athletic M54.ttf"
local bulletsParticle = {}
local particleTimer = 0
local particleSpawnInterval = 10
local score = 0
local distanceTextTimer = 0
local distanceTextInterval = 10
local speedMultiplier = 1
local distanceText

function playerJump(event)
    local phase = event.phase
    if phase == "began" then
        isHolding = true
    elseif phase == "ended" or phase == "cancelled" then
        isHolding = false
    end
end

function playerCollision(event)

    if event.phase == "began" then
        if event.other.type == "zapper" then
            gameOver = true
        end
    end
end

function moveZapper()
    zapper.x = zapper.x - (3 * speedMultiplier)  
    if zapper.x < -250 then
        local randomVal = math.random(0, 2)
        zapper.x = display.actualContentWidth
        if randomVal == 0 then
            zapper.y = 116
        else
            zapper.y = 240
        end
    end
end

local function spawnParticle()
    local bulletImg = display.newImageRect(scene.view,"assets/sprites/Bullet.png", 5, 17)
    bulletImg.x = player.x - 8
    bulletImg.y = player.y + 18

    local randomValue = math.random(0, 2)
    local speedX = (randomValue == 0) and -1.5 or (randomValue == 1) and 1.5 or 0
    bulletImg.speed = { x = speedX, y = 10 }

    table.insert(bulletsParticle, bulletImg)
end

local function moveBackground()
    local scrollSpeed = 2 * speedMultiplier

    -- Move both backgrounds
    bg1.x = bg1.x - scrollSpeed
    bg2.x = bg2.x - scrollSpeed

    -- Reset position for seamless scrolling
    if bg1.x + bg1.width / 2 < 0 then
        bg1.x = bg2.x + bg2.width
    end
    if bg2.x + bg2.width / 2 < 0 then
        bg2.x = bg1.x + bg1.width
    end
end

-- fuction untuk handle gameover
local function onGameOver(sceneGroup)
    finalScoreText = display.newText(sceneGroup, "You Flew", 411, 84, gameFonts, 30)
    scoreTextFinal = display.newText(sceneGroup, tostring(score) .. "M", 411, 120, gameFonts, 25)
    scoreTextFinal:setFillColor(1,1,0)

    restartBtn = display.newImageRect(sceneGroup, "assets/sprites/ButtonPlayAgain.png", 472/1.5, 245/1.5)
    restartBtn.x = 413
    restartBtn.y = 205

    player:setLinearVelocity(0,0)
    player:removeEventListener("collision", playerCollision)
    Runtime:removeEventListener("touch", playerJump)
    Runtime:removeEventListener("enterFrame", gameLoop)
    -- Runtime:removeEventListener("mouse", onMouse)

    local function restartGame(event)
        if event.phase == "ended" then
            finalScoreText:removeSelf()
            scoreTextFinal:removeSelf()
            restartBtn:removeSelf()

            player.x = -20
            player.y = 135
            score = 0
            zapper.x = display.actualContentWidth
            zapper.y = 116
            gameOver = false
            speedMultiplier = 1

            player:addEventListener("collision", playerCollision)
            Runtime:addEventListener("touch", playerJump)
            Runtime:addEventListener("enterFrame", gameLoop)
            -- Runtime:addEventListener("mouse", onMouse)
        end
        return true
    end

    restartBtn:addEventListener("touch", restartGame)
end

function gameLoop(event)
    if not gameOver then
        moveBackground()
        moveZapper()

    distanceText.text = "Distance " .. tostring(score)

    distanceTextTimer = distanceTextTimer + event.time / 1000
    if distanceTextTimer >= distanceTextInterval and not gameOver then
        score = score + 1
        distanceTextTimer = 0
        if score % 100 == 0 then
            speedMultiplier = speedMultiplier + 0.2  
        end
    end

   

    if isHolding then
        local px, _ = player:getLinearVelocity();
        player:setLinearVelocity(px, -200)
        playerFly.isVisible = true
        playerFly.x = player.x - 10
        playerFly.y = player.y + 40
        particleTimer = particleTimer + event.time / 1000
        if particleTimer >= particleSpawnInterval then
            spawnParticle()
            particleTimer = 0
        else
            particleTimer = particleSpawnInterval
        end
    else
        playerFly.isVisible = false
    end

    for i = #bulletsParticle, 1, -1 do
        local particle = bulletsParticle[i]
        if particle and particle.x and particle.y then
            particle.x = particle.x + particle.speed.x
            particle.y = particle.y + particle.speed.y
            if particle.y > display.actualContentHeight then
                particle:removeSelf()
                table.remove(bulletsParticle, i)
            end
        else
            table.remove(bulletsParticle, i)
        end
    end
    end

    if gameOver then
        onGameOver(scene.view)
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

    distanceText = display.newText("Distance " .. tostring(score), -15, 35, gameFonts, 20)
    distanceText.isVisible = false

    bg1 = display.newImageRect(sceneGroup,"assets/sprites/BackdropMain.png", display.actualContentWidth * 2,
    display.actualContentHeight)
    bg1.x = display.contentCenterX
    bg1.y = display.contentCenterY

    bg2 = display.newImageRect(sceneGroup,"assets/sprites/BackdropMain.png", display.actualContentWidth * 2,
    display.actualContentHeight)
    bg2.x = bg1.x + bg1.width
    bg2.y = display.contentCenterY

    zapper = display.newImageRect(sceneGroup,"assets/sprites/Zapper1.png", 46, 109)
    -- atas posisi y = 116
    -- bawah posisi y = 240
    zapper.x = display.actualContentWidth
    zapper.y = 116
    zapper.type = "zapper"
    physics.addBody(zapper, "kinematic", {isSensor=true})

    -- dua variable ini untuk boundaries atas dan bawah
    ceiling = display.newRect(sceneGroup,-88, 32, display.actualContentWidth, 10)
    ceiling.isVisible = false;
    physics.addBody(ceiling, "static", { bounce = 0 })

    floor = display.newRect(sceneGroup,-80, 296, display.actualContentWidth, 20);
    floor.isVisible = false;
    physics.addBody(floor, "static", { bounce = 0 });

    -- player variable
    playerFly = display.newImageRect(sceneGroup,"assets/sprites/FlyFire.png", 34, 34)
    playerFly.isVisible = false

    player = display.newImageRect(sceneGroup,"assets/sprites/PlayerFly.png", 53, 57)
    player.x = -20
    player.y = 135
    physics.addBody(player, { bounce = 0 })

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
        distanceText.isVisible = true
		player:addEventListener("collision", playerCollision)
        Runtime:addEventListener("touch", playerJump)
        Runtime:addEventListener("enterFrame", gameLoop)
        -- Runtime:addEventListener("mouse", onMouse)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		player:removeEventListener("collision", playerCollision)
        Runtime:removeEventListener("touch", playerJump)
        Runtime:removeEventListener("enterFrame", gameLoop)
        -- Runtime:removeEventListener("mouse", onMouse)

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
