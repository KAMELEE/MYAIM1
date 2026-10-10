import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Firestore-backed paid ads:
///
///     ads/{id}  ownerUid · providerName · title · subtitle · imageAsset · accentHex
///               package · price · status · paymentMethod · reference
///               createdAt · endsAt
///
/// An academy creates its ad as `pendingReview`; the admin confirms the bank
/// transfer and sets `status = active` + `endsAt` (Firebase Console).
/// Security rules stop academies from activating their own ads.
final class FirestoreAdsRepository: AdsRepository {

    private let db = Firestore.firestore()
    private static let collection = "ads"

    private var userId: String? { Auth.auth().currentUser?.uid }

    func liveAds() async throws -> [AcademyAd] {
        let snap = try await db.collection(Self.collection)
            .whereField("status", isEqualTo: AdStatus.active.rawValue)
            .getDocuments()
        // Expiry and ordering client-side: avoids a composite index.
        return snap.documents
            .compactMap { Self.ad(from: $0.data(), id: $0.documentID) }
            .filter(\.isLive)
            .sorted { $0.createdAt > $1.createdAt }
    }

    func myAds() async throws -> [AcademyAd] {
        guard let uid = userId else { return [] }
        let snap = try await db.collection(Self.collection)
            .whereField("ownerUid", isEqualTo: uid)
            .getDocuments()
        return snap.documents
            .compactMap { Self.ad(from: $0.data(), id: $0.documentID) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func create(_ ad: AcademyAd) async throws {
        guard let uid = userId else { return }
        var data: [String: Any] = [
            "ownerUid": uid,
            "providerName": ad.providerName,
            "title": ad.title,
            "subtitle": ad.subtitle,
            "accentHex": ad.accentHex,
            "package": ad.package.rawValue,
            "days": ad.package.days,
            "price": ad.package.price,
            "status": AdStatus.pendingReview.rawValue,
            "paymentMethod": ad.paymentMethod.rawValue,
            "reference": ad.reference,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let image = ad.imageAsset { data["imageAsset"] = image }
        try await db.collection(Self.collection).document(ad.id.uuidString).setData(data)
    }

    private static func ad(from data: [String: Any], id: String) -> AcademyAd? {
        guard let title = data["title"] as? String,
              let providerName = data["providerName"] as? String
        else { return nil }
        return AcademyAd(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            subtitle: data["subtitle"] as? String ?? "",
            providerName: providerName,
            imageAsset: data["imageAsset"] as? String,
            accentHex: data["accentHex"] as? String ?? "#5B3FBF",
            ownerUid: data["ownerUid"] as? String,
            package: AdPackage(rawValue: data["package"] as? String ?? "") ?? .week,
            status: AdStatus(rawValue: data["status"] as? String ?? "") ?? .pendingReview,
            paymentMethod: PaymentMethod(rawValue: data["paymentMethod"] as? String ?? "") ?? .bankTransfer,
            reference: data["reference"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            endsAt: (data["endsAt"] as? Timestamp)?.dateValue()
        )
    }
}
