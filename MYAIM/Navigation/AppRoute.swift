import Foundation

/// Type-safe navigation destinations pushed onto a tab's NavigationStack.
enum AppRoute: Hashable {
    case serviceDetail(Service)
    case providerProfile(Provider)
    case category(ServiceCategory)
    case allServices(title: String)
    case search
    case notifications
    case favorites
    case goalDetail(Goal)
    case createGoal
    case registerAcademy
    case booking(Service)
    case settings
    case messages
    case chat(Conversation)
    // Provider (academy) interface
    case addCourse
    case publishPost
    case courseDetail(Course)
}
