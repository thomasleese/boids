//
//  Boid.swift
//  Boids
//
//  Created by Thomas Leese on 11/10/2016.
//  Copyright © 2016 Thomas Leese. All rights reserved.
//

import SpriteKit

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

public func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
}

public func /= (left: inout CGPoint, right: CGFloat) {
    left = left / right
}

public func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

public func *= (left: inout CGPoint, right: CGFloat) {
    left = left * right
}

public class Boid: SKShapeNode {

    var velocity: CGPoint = CGPoint(x: 0, y: 0)

    init(x: CGFloat, y: CGFloat) {
        super.init()

        let diameter = 10
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint(), size: CGSize(width: diameter, height: diameter)), transform: nil)
        self.strokeColor = SKColor.gray
        self.glowWidth = 1.0
        self.fillColor = SKColor.gray
        self.position = CGPoint(x: x, y: y)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func findSwarmCentre(boids: [Boid]) -> CGPoint {
        var centre: CGPoint = CGPoint(x: 0, y: 0)

        for boid in boids {
            if boid != self {
                centre += boid.position
            }
        }

        centre /= CGFloat(boids.count - 1)

        return centre
    }

    func dist2(a: CGPoint, b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return (dx * dx) + (dy * dy)
    }

    func len2(v: CGPoint) -> CGFloat {
        return v.x * v.x + v.y * v.y
    }

    func keepDistance(boids: [Boid]) -> CGPoint {
        var velocity: CGPoint = CGPoint(x: 0, y: 0)

        let limit = 25

        for boid in boids {
            if boid != self {
                if dist2(a: self.position, b: boid.position) < CGFloat(limit * limit) {
                    velocity -= (boid.position - self.position) / 20.0
                }
            }
        }

        return velocity
    }

    func matchVelocity(boids: [Boid]) -> CGPoint {
        var velocity: CGPoint = CGPoint(x: 0, y: 0)

        for boid in boids {
            if boid != self {
                velocity += boid.velocity
            }
        }

        velocity /= CGFloat(boids.count - 1)

        return (velocity - self.velocity) / 80.0
    }

    func boundToWalls(hw: CGFloat, hh: CGFloat) {
        let m = CGFloat(5.0)

        if self.position.x < -hw {
            self.velocity.x += m
        }

        if self.position.x > hw {
            self.velocity.x -= m
        }

        if self.position.y < -hh {
            self.velocity.y += m
        }

        if self.position.y > hh {
            self.velocity.y -= m
        }
    }

    func limitVelocity() {
        let limit = CGFloat(15.0)

        if len2(v: self.velocity) > (limit * limit) {
            self.velocity = (self.velocity / sqrt(len2(v: self.velocity))) * limit
        }
    }

    func update(boids: [Boid], hw: CGFloat, hh: CGFloat) {
        let centre = findSwarmCentre(boids: boids)

        let v1 = (centre - self.position) / 250.0
        let v2 = keepDistance(boids: boids)
        let v3 = matchVelocity(boids: boids)

        self.velocity += v1 + v2 + v3
        self.position += self.velocity

        boundToWalls(hw: hw, hh: hh)
        limitVelocity()
    }
    
}
