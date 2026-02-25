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

                Text("\(place.visitCount) visits")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
