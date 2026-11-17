
import SwiftUI

enum Level: Int {
    case L1 = 1
    case L2 = 2
    case L3 = 3
    case L4 = 4

    var gridCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }

    var litWindow: Double {
        switch self {
        case .L1: return 1.2
        case .L2: return 0.9
        case .L3: return 0.7
        case .L4: return 0.5
        }
    }

    var tickInterval: Double {
        switch self {
        case .L1: return 1.8
        case .L2: return 1.4
        case .L3: return 1.1
        case .L4: return 0.8
        }
    }
}

