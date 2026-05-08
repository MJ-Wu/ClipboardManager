import AppKit
import Combine

class ClipboardMonitor: ObservableObject {
    private var timer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        // 优先检测图片
        if let image = NSImage(pasteboard: pasteboard),
           let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            // 限制图片大小（5MB 以内）
            if pngData.count < 5 * 1024 * 1024 {
                ClipboardStore.shared.add(item: ClipboardItem(imageData: pngData))
                return
            }
        }

        // 其次检测文本
        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            ClipboardStore.shared.add(item: ClipboardItem(content: string))
        }
    }

    deinit {
        stop()
    }
}

// 扩展 NSImage 以支持从粘贴板初始化
extension NSImage {
    convenience init?(pasteboard: NSPasteboard) {
        // 尝试读取 TIFF 数据
        if let data = pasteboard.data(forType: .tiff),
           let image = NSImage(data: data), image.isValid {
            self.init(data: data)
            return
        }
        // 尝试读取 PNG 数据
        if let data = pasteboard.data(forType: .png),
           let image = NSImage(data: data), image.isValid {
            self.init(data: data)
            return
        }
        // 尝试读取文件URL（截图等）
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL],
           let url = urls.first,
           url.isFileURL,
           let image = NSImage(contentsOf: url), image.isValid {
            self.init(contentsOf: url)
            return
        }
        return nil
    }
}
