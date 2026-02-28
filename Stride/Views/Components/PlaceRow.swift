import SwiftUI

struct PlaceRow: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name)
                .font(.headline)

            Text(place.address)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Text(place.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(4)

                if let rating = place.rating {
                    Text("\(rating)/5")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                Spacer()

                if place.visitCount > 0 {
                    Text("Visited \(place.visitCount)×")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            if !place.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(place.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.12))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
