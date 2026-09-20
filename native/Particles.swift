import Foundation

struct Particle {
    let fromRight: Bool
    let delay: Double
    let speedX: Double
    let speedY: Double
    let phase: Double
    let spin: Double
    let size: Double
    let color: Int
    let rounded: Bool

    static func make<R: RandomNumberGenerator>(count: Int, using random: inout R) -> [Particle] {
        (0..<count).map { index in
            Particle(
                fromRight: index.isMultiple(of: 2),
                delay: .random(in: 0...0.55, using: &random),
                speedX: .random(in: 0.14...0.48, using: &random),
                speedY: .random(in: 0.88...1.30, using: &random),
                phase: .random(in: 0...(2 * .pi), using: &random),
                spin: .random(in: -7...7, using: &random),
                size: .random(in: 6...12, using: &random),
                color: .random(in: 0..<7, using: &random),
                rounded: index.isMultiple(of: 5)
            )
        }
    }

    func frame(at time: Double, width: Double, height: Double, reducedMotion: Bool) -> ParticleFrame? {
        let duration = reducedMotion ? 1.3 : 5.5
        guard time >= 0, time < duration else { return nil }
        if reducedMotion {
            return ParticleFrame(
                x: width * (0.1 + speedX * 1.65),
                y: height * (0.15 + (speedY - 0.88) * 1.6),
                angle: phase, scaleX: 1,
                opacity: min(1, time / 0.2, (duration - time) / 0.4)
            )
        }
        let age = time - delay
        guard age >= 0 else { return nil }
        let travel = speedX * width * (1 - exp(-0.6 * age)) / 0.6
        let x = (fromRight ? width * 0.95 - travel : width * 0.05 + travel)
            + sin(age * 3 + phase) * 12 * age
        let y = height * (-0.04 + speedY * age - 0.25 * age * age)
        return ParticleFrame(
            x: x, y: y, angle: phase + spin * age,
            scaleX: 0.25 + abs(cos(phase + age * 7)) * 0.75,
            opacity: min(1, (duration - time) / 0.8)
        )
    }
}

struct ParticleFrame {
    let x: Double
    let y: Double
    let angle: Double
    let scaleX: Double
    let opacity: Double
}
