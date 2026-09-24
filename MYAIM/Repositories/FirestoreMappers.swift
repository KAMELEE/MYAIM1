import Foundation
import FirebaseFirestore

/// Hand-mapping between Firestore documents ([String: Any]) and MY AIM models.
/// Kept in one place so every repository shares identical field names.
enum FirestoreMappers {

    // MARK: - Service

    static func serviceData(_ s: Service) -> [String: Any] {
        var location: [String: Any] = ["city": s.location.city,
                                       "latitude": s.location.latitude,
                                       "longitude": s.location.longitude]
        if let district = s.location.district { location["district"] = district }
        var data: [String: Any] = [
            "title": s.title,
            "summary": s.summary,
            "category": s.category.rawValue,
            "providerName": s.providerName,
            "providerId": s.providerId.uuidString,
            "isVerified": s.isVerified,
            "rating": s.rating,
            "reviewsCount": s.reviewsCount,
            "startingPrice": s.startingPrice,
            "location": location,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let url = s.imageURL { data["imageURL"] = url }
        return data
    }

    static func service(from data: [String: Any], id: String) -> Service? {
        guard let title = data["title"] as? String,
              let summary = data["summary"] as? String,
              let categoryRaw = data["category"] as? String,
              let category = ServiceCategory(rawValue: categoryRaw),
              let providerName = data["providerName"] as? String,
              let providerIdStr = data["providerId"] as? String,
              let providerId = UUID(uuidString: providerIdStr),
              let rating = data["rating"] as? Double,
              let reviewsCount = data["reviewsCount"] as? Int,
              let startingPrice = data["startingPrice"] as? Double,
              let locationData = data["location"] as? [String: Any],
              let city = locationData["city"] as? String,
              let latitude = locationData["latitude"] as? Double,
              let longitude = locationData["longitude"] as? Double
        else { return nil }

        let district = locationData["district"] as? String
        let isVerified = data["isVerified"] as? Bool ?? false
        let imageURL = data["imageURL"] as? String
        let distance = data["distanceMeters"] as? Double

        return Service(id: UUID(uuidString: id) ?? UUID(),
                       title: title,
                       summary: summary,
                       category: category,
                       providerName: providerName,
                       providerId: providerId,
                       isVerified: isVerified,
                       rating: rating,
                       reviewsCount: reviewsCount,
                       location: MYLocation(city: city, district: district,
                                            latitude: latitude, longitude: longitude),
                       startingPrice: startingPrice,
                       imageURL: imageURL,
                       distanceMeters: distance)
    }

    // MARK: - Booking

    static func bookingData(userId: String, service: Service,
                            date: Date, time: String, status: BookingStatus) -> [String: Any] {
        [
            "userId": userId,
            "serviceId": service.id.uuidString,
            "serviceSnapshot": serviceData(service),
            "date": Timestamp(date: date),
            "time": time,
            "status": status.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ]
    }

    static func booking(from data: [String: Any], id: String) -> Booking? {
        guard let statusRaw = data["status"] as? String,
              let status = BookingStatus(rawValue: statusRaw),
              let time = data["time"] as? String,
              let dateTs = data["date"] as? Timestamp,
              let serviceSnapshot = data["serviceSnapshot"] as? [String: Any]
        else { return nil }
        guard let service = service(from: serviceSnapshot,
                                    id: (data["serviceId"] as? String) ?? id)
        else { return nil }
        return Booking(id: UUID(uuidString: id) ?? UUID(),
                       service: service,
                       date: dateTs.dateValue(),
                       time: time,
                       status: status)
    }

    // MARK: - Goal

    static func goalData(userId: String, goal: Goal) -> [String: Any] {
        [
            "userId": userId,
            "title": goal.title,
            "category": goal.category.rawValue,
            "steps": goal.steps.map { ["title": $0.title, "isDone": $0.isDone] },
            "createdAt": Timestamp(date: goal.createdAt)
        ]
    }

    static func goal(from data: [String: Any], id: String) -> Goal? {
        guard let title = data["title"] as? String,
              let categoryRaw = data["category"] as? String,
              let category = ServiceCategory(rawValue: categoryRaw),
              let stepsData = data["steps"] as? [[String: Any]]
        else { return nil }
        let steps = stepsData.compactMap { d -> GoalStep? in
            guard let t = d["title"] as? String else { return nil }
            return GoalStep(title: t, isDone: d["isDone"] as? Bool ?? false)
        }
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        return Goal(id: UUID(uuidString: id) ?? UUID(),
                    title: title,
                    category: category,
                    steps: steps,
                    createdAt: createdAt)
    }
}
