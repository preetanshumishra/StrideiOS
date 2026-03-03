import Foundation

#if DEBUG
enum PreviewData {

    // MARK: - User

    static let user = User(
        id: "u1",
        email: "alex@stride.app",
        firstName: "Alex",
        lastName: "Stride"
    )

    // MARK: - Collections

    static let collection1 = PlaceCollection(
        id: "c1", userId: "u1",
        name: "Favourites",
        description: "My go-to spots around the city",
        icon: "star", shared: false,
        createdAt: "2026-01-01T00:00:00Z",
        updatedAt: "2026-01-01T00:00:00Z"
    )

    static let collection2 = PlaceCollection(
        id: "c2", userId: "u1",
        name: "Work Spots",
        description: "Places I like to work from",
        icon: "briefcase", shared: false,
        createdAt: "2026-01-05T00:00:00Z",
        updatedAt: "2026-01-05T00:00:00Z"
    )

    static let collections = [collection1, collection2]

    // MARK: - Places

    static let place1 = Place(
        id: "p1", userId: "u1",
        name: "Whole Foods Market",
        address: "123 Main St, San Francisco, CA",
        latitude: 37.7749, longitude: -122.4194,
        category: "Grocery",
        tags: ["organic", "fresh"],
        notes: "Good produce section",
        rating: 4,
        collectionId: nil,
        visitCount: 12,
        lastVisited: "2026-02-15T10:00:00Z",
        source: "manual",
        createdAt: "2026-01-01T00:00:00Z",
        updatedAt: "2026-02-15T10:00:00Z",
        distanceKm: 0.4
    )

    static let place2 = Place(
        id: "p2", userId: "u1",
        name: "Philz Coffee",
        address: "456 Market St, San Francisco, CA",
        latitude: 37.7751, longitude: -122.4180,
        category: "Coffee",
        tags: ["work-friendly", "pour-over"],
        notes: "Great pour-over, strong wifi",
        rating: 5,
        collectionId: "c1",
        visitCount: 30,
        lastVisited: "2026-03-01T08:30:00Z",
        source: "manual",
        createdAt: "2026-01-10T00:00:00Z",
        updatedAt: "2026-03-01T08:30:00Z",
        distanceKm: 0.7
    )

    static let place3 = Place(
        id: "p3", userId: "u1",
        name: "Tartine Bakery",
        address: "600 Guerrero St, San Francisco, CA",
        latitude: 37.7618, longitude: -122.4241,
        category: "Bakery",
        tags: ["breakfast", "pastries"],
        notes: "Worth the queue",
        rating: 5,
        collectionId: "c2",
        visitCount: 5,
        lastVisited: nil,
        source: "manual",
        createdAt: "2026-01-20T00:00:00Z",
        updatedAt: "2026-01-20T00:00:00Z",
        distanceKm: 2.1
    )

    static let places = [place1, place2, place3]

    // MARK: - Errands

    static let errand1 = Errand(
        id: "e1", userId: "u1",
        title: "Pick up groceries",
        category: "Shopping",
        linkedPlaceId: "p1",
        priority: "high",
        deadline: "2026-03-05T18:00:00Z",
        recurring: nil,
        status: "pending",
        completedAt: nil,
        createdAt: "2026-03-01T00:00:00Z",
        updatedAt: "2026-03-01T00:00:00Z",
        distanceKm: 0.4
    )

    static let errand2 = Errand(
        id: "e2", userId: "u1",
        title: "Morning coffee run",
        category: "Personal",
        linkedPlaceId: "p2",
        priority: "low",
        deadline: nil,
        recurring: Recurring(interval: 1, unit: "days"),
        status: "pending",
        completedAt: nil,
        createdAt: "2026-02-20T00:00:00Z",
        updatedAt: "2026-02-20T00:00:00Z",
        distanceKm: 0.7
    )

    static let errand3 = Errand(
        id: "e3", userId: "u1",
        title: "Get bread from Tartine",
        category: "Shopping",
        linkedPlaceId: "p3",
        priority: "medium",
        deadline: "2026-03-10T12:00:00Z",
        recurring: nil,
        status: "done",
        completedAt: "2026-03-02T11:00:00Z",
        createdAt: "2026-02-28T00:00:00Z",
        updatedAt: "2026-03-02T11:00:00Z",
        distanceKm: 2.1
    )

    static let errands = [errand1, errand2, errand3]
}
#endif
