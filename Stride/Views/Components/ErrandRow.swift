import SwiftUI

struct ErrandRow: View {
    let errand: Errand
    var onComplete: (() -> Void)? = nil

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

            if let deadlineStr = errand.deadline, let date = parseDeadline(deadlineStr) {
                Label(
                    DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none),
                    systemImage: "calendar"
                )
                .font(.caption2)
                .foregroundColor(date < Date() ? .red : .secondary)
            }

            if let onComplete, errand.status == "pending" {
                Button(action: onComplete) {
                    Label("Complete", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }

    private func parseDeadline(_ str: String) -> Date? {
        let full = ISO8601DateFormatter()
        full.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let basic = ISO8601DateFormatter()
        basic.formatOptions = [.withInternetDateTime]
        return full.date(from: str) ?? basic.date(from: str)
    }

    private var priorityColor: Color {
        switch errand.priority {
        case "high": return .red
        case "medium": return .orange
        default: return .green
        }
    }
}
