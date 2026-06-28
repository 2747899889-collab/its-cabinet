import SwiftUI
import UIKit

struct CabinetItemRow: View {
    let item: CabinetItem
    let status: ExpiryStatus

    var body: some View {
        HStack(spacing: 12) {
            itemImage

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)

                Text("\(item.quantity)\(item.unit) · \(expiryText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(statusText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.12), in: Capsule())
        }
        .padding(.vertical, 6)
        .opacity(isExpired ? 0.58 : 1)
    }

    @ViewBuilder
    private var itemImage: some View {
        if let imageData = item.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(.secondary.opacity(0.12))
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: "shippingbox")
                        .foregroundStyle(.secondary)
                }
        }
    }

    private var expiryText: String {
        item.expiryDate.formatted(.dateTime.year().month().day())
    }

    private var statusText: String {
        switch status {
        case .safe(let daysRemaining):
            return "\(daysRemaining)天"
        case .warning(let daysRemaining):
            return "临期\(daysRemaining)天"
        case .expired(let daysOverdue):
            return "已过\(daysOverdue)天"
        }
    }

    private var statusColor: Color {
        switch status {
        case .safe:
            return .green
        case .warning:
            return .orange
        case .expired:
            return .red
        }
    }

    private var isExpired: Bool {
        if case .expired = status {
            return true
        }
        return false
    }
}

#Preview {
    CabinetItemRow(
        item: CabinetItem(
            name: "幼猫主粮",
            productionDate: .now,
            shelfLifeValue: 12,
            shelfLifeUnit: .months,
            expiryDate: .now,
            quantity: 2,
            unit: "包"
        ),
        status: .warning(daysRemaining: 7)
    )
    .padding()
}
