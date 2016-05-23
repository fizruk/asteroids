module Bullet
(
    Bullet(..),
    initBullet,
    bulletSpeed
) where

import Types
import Ship


bulletSpeed :: Float
bulletSpeed = 300


data Bullet = Bullet {
    bulLoc :: Position,
    bulAng :: Degree,
    bulRad :: Radius,
    bulVel :: Speed,
    bulAlive :: Bool
} deriving (Show, Eq)



initBullet :: Ship -> Bullet
initBullet s =
    Bullet {
        bulLoc = shipLoc s,
        bulRad = 3,
        bulAng = shipAng s,
        bulAlive = True,
        bulVel = velang
    }
    where
        yvel = cos ((shipAng s) * pi / 180)
        xvel = sin ((shipAng s) * pi / 180)
        norm = sqrt (xvel * xvel + yvel * yvel)
        velang = (xvel /norm * bulletSpeed, yvel /norm * bulletSpeed)