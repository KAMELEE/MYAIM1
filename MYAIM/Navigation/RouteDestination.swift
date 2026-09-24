import SwiftUI

/// Maps an `AppRoute` to its destination view. Attached once per NavigationStack.
struct RouteDestination: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .serviceDetail(let service):
            ServiceDetailView(service: service)

        case .providerProfile(let provider):
            ProviderProfileView(provider: provider)

        case .category(let category):
            AllServicesView(title: category.title, category: category)

        case .allServices(let title):
            AllServicesView(title: title, category: nil)

        case .search:
            SearchView()

        case .notifications:
            NotificationsView()

        case .favorites:
            FavoritesView()

        case .goalDetail(let goal):
            GoalDetailView(goal: goal)

        case .createGoal:
            CreateGoalView()

        case .registerAcademy:
            RegisterAcademyView()

        case .booking(let service):
            BookingView(service: service)

        case .settings:
            SettingsView()

        case .messages:
            MessagesView()

        case .chat(let conversation):
            ChatView(conversation: conversation)

        case .addCourse:
            AddCourseView()

        case .publishPost:
            PublishPostView()

        case .publishStory:
            PublishStoryView()

        case .publishAd:
            PublishAdView()

        case .courseDetail(let course):
            CourseDetailView(course: course)
        }
    }
}

extension View {
    /// Registers all app route destinations on the current NavigationStack.
    func withAppRoutes() -> some View {
        self.navigationDestination(for: AppRoute.self) { route in
            RouteDestination(route: route)
        }
    }
}
