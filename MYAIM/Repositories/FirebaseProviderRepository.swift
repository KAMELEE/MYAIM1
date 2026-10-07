import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Firestore-backed academy dashboard, one document per signed-in account:
///
///     providers/{uid}               name · tagline · category · planName
///     providers/{uid}/courses/{id}  Course
///     providers/{uid}/posts/{id}    Post
final class FirestoreProviderRepository: ProviderRepository {

    private let db = Firestore.firestore()
    private static let collection = "providers"

    private var userId: String? { Auth.auth().currentUser?.uid }

    private func root(_ uid: String) -> DocumentReference {
        db.collection(Self.collection).document(uid)
    }

    func load() async throws -> ProviderProfile? {
        guard let uid = userId else { return nil }
        let doc = try await root(uid).getDocument()
        guard let data = doc.data() else { return nil }

        async let coursesSnap = root(uid).collection("courses").getDocuments()
        async let postsSnap = root(uid).collection("posts").getDocuments()

        let courses = try await coursesSnap.documents
            .compactMap { FirestoreMappers.course(from: $0.data(), id: $0.documentID) }
            .sorted { $0.createdAt > $1.createdAt }
            .map { $0.course }
        let posts = try await postsSnap.documents
            .compactMap { FirestoreMappers.post(from: $0.data(), id: $0.documentID) }
            .sorted { $0.date > $1.date }

        return ProviderProfile(
            academyName: data["academyName"] as? String ?? "",
            academyTagline: data["academyTagline"] as? String ?? "",
            category: ServiceCategory(rawValue: data["category"] as? String ?? "") ?? .sports,
            planName: data["planName"] as? String ?? "",
            courses: courses,
            posts: posts
        )
    }

    func saveProfile(_ profile: ProviderProfile) async throws {
        guard let uid = userId else { return }
        try await root(uid).setData([
            "ownerId": uid,
            "academyName": profile.academyName,
            "academyTagline": profile.academyTagline,
            "category": profile.category.rawValue,
            "planName": profile.planName,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func saveCourse(_ course: Course) async throws {
        guard let uid = userId else { return }
        try await root(uid).collection("courses")
            .document(course.id.uuidString)
            .setData(FirestoreMappers.courseData(course), merge: true)
    }

    func savePost(_ post: Post) async throws {
        guard let uid = userId else { return }
        try await root(uid).collection("posts")
            .document(post.id.uuidString)
            .setData(FirestoreMappers.postData(post))
    }
}

// MARK: - Mappers

extension FirestoreMappers {

    static func courseData(_ c: Course) -> [String: Any] {
        [
            "title": c.title,
            "category": c.category.rawValue,
            "price": c.price,
            "students": c.students,
            "rating": c.rating,
            "isPublished": c.isPublished,
            "summary": c.summary,
            // merge:true keeps the original value on later updates.
            "createdAt": FieldValue.serverTimestamp()
        ]
    }

    static func course(from data: [String: Any], id: String) -> (course: Course, createdAt: Date)? {
        guard let title = data["title"] as? String,
              let category = ServiceCategory(rawValue: data["category"] as? String ?? "")
        else { return nil }
        let course = Course(id: UUID(uuidString: id) ?? UUID(),
                            title: title,
                            category: category,
                            price: (data["price"] as? NSNumber)?.doubleValue ?? 0,
                            students: (data["students"] as? NSNumber)?.intValue ?? 0,
                            rating: (data["rating"] as? NSNumber)?.doubleValue ?? 0,
                            isPublished: data["isPublished"] as? Bool ?? false,
                            summary: data["summary"] as? String ?? "")
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? .distantPast
        return (course, createdAt)
    }

    static func postData(_ p: Post) -> [String: Any] {
        var data: [String: Any] = [
            "text": p.text,
            "date": Timestamp(date: p.date),
            "likes": p.likes,
            "comments": p.comments
        ]
        if let image = p.imageName { data["imageName"] = image }
        return data
    }

    static func post(from data: [String: Any], id: String) -> Post? {
        guard let text = data["text"] as? String else { return nil }
        return Post(id: UUID(uuidString: id) ?? UUID(),
                    text: text,
                    date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                    likes: (data["likes"] as? NSNumber)?.intValue ?? 0,
                    comments: (data["comments"] as? NSNumber)?.intValue ?? 0,
                    imageName: data["imageName"] as? String)
    }
}
