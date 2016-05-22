{-# LANGUAGE RecordWildCards #-}
module Game
(
    GameState(..),
    Universe(..),
    updateGame,
    width,
    height,
    initUniverse
) where

import Types
import GraphObject
import Ship
import Asteroid
import Bullet
import Universe
import Collisions

import System.Random

--add alternative states here, like 'pause', 'settings' and so on
data GameState =
    InGame Universe
    | GameOver


generateAstPosition :: Ship -> [Float] -> Position
generateAstPosition ship (x:y:xs)
    | twoCirclesCollide (shipLoc ship) (shipSize ship) (x, y) 50 =
        generateAstPosition ship xs
    | otherwise = (x, y)
-- TODO: should be handling this case more appropriately
generateAstPosition _ [] = (0, 0)
generateAstPosition _ [_] = (0, 0)

{-
addAsteroid :: Universe -> Universe
addAsteroid u@Universe{..} =
    if (step == 60)
        then u {
            step = 0,
            asteroids = (a : asteroids)
        }
        else u
    where
        genX = mkStdGen (round (foldr (+) 1 (map (fst . astLoc) asteroids)))
        randLoc = generateAstPosition ship (randomRs ((-200)::Float, 200::Float) genX)
        genY = mkStdGen (round (foldr (+) 1 (map (snd . astLoc) asteroids)))
        randSpeed = take 2 (randomRs ((-70)::Float, 70::Float) genY)
        randVel = (head randSpeed, head (tail randSpeed))
        genAst = mkStdGen (length asteroids)
        randInt = take 1 (randomRs (10::Float, 50::Float) genAst)
        randRad = head randInt
        a = Asteroid {astLoc = randLoc, astAng = 0, astRad = randRad, astAlive = True, astVel = randVel}
-}
addAsteroid :: Universe -> Universe
addAsteroid u@Universe{..} =
    if (step == 60)
        then u {
            step = 0,
            asteroids = (a : asteroids),
            randLoc = drop 2 randLoc,
            randVel = drop 2 randVel,
            randRad = drop 1 randRad
        }
        else u
    where
        newLoc = generateAstPosition ship randLoc
        randSpeed = take 2 randVel
        newVel = (head randSpeed, head (tail randSpeed))
        newRad = head (take 1 randRad)
        a = Asteroid {astLoc = newLoc, astAng = 0, astRad = newRad, astAlive = True, astVel = newVel}


--check collisions for all objects
checkCollisions :: Universe -> Universe
checkCollisions u@Universe{..} =
    u {
        ship = checkCollisionsWithOthers u ship,
        asteroids = map (checkCollisionsWithOthers u) asteroids,
        bullets = map (checkCollisionsWithOthers u) bullets
    }


moveAllObjects :: Time -> Universe -> Universe
moveAllObjects sec u@Universe{..} =
    u {
        ship = move sec ship,
        asteroids = map (move sec) asteroids,
        bullets = map (move sec) bullets
    }


delObjects :: Universe -> Universe
delObjects u@Universe{..} =
    u {
        asteroids = (filter (\ast -> astAlive ast) asteroids),
        bullets = (filter (\bul -> bulAlive bul) bullets)
    }


updateObjects :: Universe -> Universe
updateObjects u@Universe{..} =
    u {
        ship = updateShip ship
    }


updateGame :: Time -> GameState -> GameState
updateGame _ GameOver = GameOver
updateGame sec (InGame u@Universe{..})
    | not $ shipAlive ship = GameOver
    | otherwise =
        InGame $ chain $ u {
            step = step + 1
        }
    where
        chain =
            (addAsteroid . delObjects . checkCollisions . updateObjects . moveAllObjects sec)
