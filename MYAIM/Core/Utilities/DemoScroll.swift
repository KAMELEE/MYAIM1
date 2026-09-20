#if DEBUG
import UIKit

/// DEBUG-only: reads launch args used by CI to deep-link into a screen.
enum DemoLaunch {
    static func arg(_ key: String) -> String? {
        let a = ProcessInfo.processInfo.arguments
        if let i = a.firstIndex(of: key), i + 1 < a.count { return a[i + 1] }
        return nil
    }
    static var route: String? { arg("-demoRoute") }
}

/// DEBUG-only helper: when launched with `-scrollTo <fraction 0...1>`, scrolls the
/// largest on-screen scroll view to that fraction so CI can screenshot full
/// screens at top / middle / bottom. Never used in release builds.
enum DemoScroll {
    static func applyIfNeeded() {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-scrollTo"), i + 1 < args.count,
              let fraction = Double(args[i + 1]) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            perform(fraction)
        }
    }

    private static func perform(_ fraction: Double) {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        guard let window = windows.first(where: { $0.isKeyWindow }) ?? windows.first else { return }

        var best: UIScrollView?
        var bestHeight: CGFloat = 0
        func walk(_ view: UIView) {
            if let sv = view as? UIScrollView, sv.contentSize.height > bestHeight {
                bestHeight = sv.contentSize.height
                best = sv
            }
            view.subviews.forEach(walk)
        }
        walk(window)

        if let sv = best {
            let maxY = max(0, sv.contentSize.height - sv.bounds.height)
            sv.setContentOffset(CGPoint(x: 0, y: maxY * CGFloat(fraction)), animated: false)
        }
    }
}
#endif
