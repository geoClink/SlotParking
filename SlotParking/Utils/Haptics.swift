import Foundation
import UIKit

enum Haptics {
    static func success() {
        DispatchQueue.main.async {
            let g = UINotificationFeedbackGenerator()
            g.prepare()
            g.notificationOccurred(.success)
        }
    }

    static func error() {
        DispatchQueue.main.async {
            let g = UINotificationFeedbackGenerator()
            g.prepare()
            g.notificationOccurred(.error)
        }
    }

    static func warning() {
        DispatchQueue.main.async {
            let g = UINotificationFeedbackGenerator()
            g.prepare()
            g.notificationOccurred(.warning)
        }
    }

    static func lightImpact() {
        DispatchQueue.main.async {
            let g = UIImpactFeedbackGenerator(style: .light)
            g.prepare()
            g.impactOccurred()
        }
    }

    static func mediumImpact() {
        DispatchQueue.main.async {
            let g = UIImpactFeedbackGenerator(style: .medium)
            g.prepare()
            g.impactOccurred()
        }
    }

    static func heavyImpact() {
        DispatchQueue.main.async {
            let g = UIImpactFeedbackGenerator(style: .heavy)
            g.prepare()
            g.impactOccurred()
        }
    }

    static func selectionChanged() {
        DispatchQueue.main.async {
            let g = UISelectionFeedbackGenerator()
            g.prepare()
            g.selectionChanged()
        }
    }
}
