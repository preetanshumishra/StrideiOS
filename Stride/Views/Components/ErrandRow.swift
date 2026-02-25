import SwiftUI

struct ErrandRow: View {
    let errand: Errand

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(errand.title)
                    .font(.headline)
                    .strikethrough(errand.status == "done")

                Spacer()

                Text(errand.priority)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(priorityColor.opacity(0.1))
                    .foregroundColor(priorityColor)
                    .cornerRadius(4)
            }

            Text(errand.category)
                .font(.subheadline)
                .foregroundColor(.gray)

            if let deadline = errand.deadline {
                Text("Due: \(deadline)")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }

    private var priorityColor: Color {
        switch errand.priority {
        case "high": return .red
        case "medium": return .orange
        default: return .green
        }
    }
}
