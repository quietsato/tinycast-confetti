import Foundation

@main
enum ParticlesTests {
    static func main() {
        var random = SystemRandomNumberGenerator()
        let particles = Particle.make(count: 360, using: &random)
        precondition(particles.count == 360)
        precondition(particles.filter(\.fromRight).count == 180)
        for particle in particles {
            precondition(particle.frame(at: -1, width: 1440, height: 900, reducedMotion: false) == nil)
            precondition(particle.frame(at: 5.5, width: 1440, height: 900, reducedMotion: false) == nil)
            precondition(particle.frame(at: 1.3, width: 1440, height: 900, reducedMotion: true) == nil)
            let a = particle.frame(at: 0.4, width: 1440, height: 900, reducedMotion: true)!
            let b = particle.frame(at: 0.8, width: 1440, height: 900, reducedMotion: true)!
            precondition(a.x == b.x && a.y == b.y && a.angle == b.angle)
            precondition((0...1440).contains(a.x) && (0...900).contains(a.y))
            for time in stride(from: 0.0, to: 5.5, by: 0.05) {
                if let frame = particle.frame(at: time, width: 1440, height: 900, reducedMotion: false) {
                    precondition(frame.x.isFinite && frame.y.isFinite && frame.angle.isFinite)
                    precondition((0...1).contains(frame.opacity))
                    precondition((0.25...1).contains(frame.scaleX))
                }
            }
        }
        print("Particle lifetime, motion, reduced-motion and bounds checks passed")
    }
}
