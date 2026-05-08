import Foundation
import AppKit

enum ClipboardContentType: String, Codable {
    case text
    case image
}

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let contentType: ClipboardContentType
    let content: String          // 文本内容，图片时为空
    let imageData: Data?         // 图片 PNG 数据，文本时为 nil
    let date: Date

    init(content: String) {
        self.id = UUID()
        self.contentType = .text
        self.content = content
        self.imageData = nil
        self.date = Date()
    }

    init(imageData: Data) {
        self.id = UUID()
        self.contentType = .image
        self.content = ""
        self.imageData = imageData
        self.date = Date()
    }

    // 用于去重比较
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        guard lhs.contentType == rhs.contentType else { return false }
        if lhs.contentType == .text {
            return lhs.content == rhs.content
        } else {
            return lhs.imageData == rhs.imageData
        }
    }

    var preview: String {
        if contentType == .image {
            return "📷 图片"
        }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 120 {
            return String(trimmed.prefix(120)) + "..."
        }
        return trimmed
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // 获取 NSImage（仅图片类型）
    var nsImage: NSImage? {
        guard let data = imageData else { return nil }
        return NSImage(data: data)
    }

    // 图片尺寸描述
    var imageSizeText: String? {
        guard let img = nsImage else { return nil }
        return "\(Int(img.size.width))×\(Int(img.size.height))"
    }
}

class ClipboardStore: ObservableObject {
    static let shared = ClipboardStore()

    @Published var items: [ClipboardItem] = []
    private let maxItems = 10
    private let saveKey = "clipboard_history_v2"

    private init() {
        load()
    }

    func add(item: ClipboardItem) {
        // Avoid duplicates of the most recent item
        if let first = items.first, first == item { return }

        DispatchQueue.main.async {
            self.items.insert(item, at: 0)
            if self.items.count > self.maxItems {
                self.items = Array(self.items.prefix(self.maxItems))
            }
            self.save()
        }
    }

    func paste(item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.contentType {
        case .text:
            pasteboard.setString(item.content, forType: .string)
        case .image:
            if let data = item.imageData {
                pasteboard.setData(data, forType: .tiff)
            }
        }
    }

    func delete(item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func clear() {
        items.removeAll()
        save()
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        // 尝试加载 v2 格式
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let saved = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            items = saved
            return
        }
        // 兼容旧版本（纯文本数据）
        let oldKey = "clipboard_history"
        if let data = UserDefaults.standard.data(forKey: oldKey),
           let saved = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            items = saved
            save()
            UserDefaults.standard.removeObject(forKey: oldKey)
        }
    }
}
