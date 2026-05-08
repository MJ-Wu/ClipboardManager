import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var store = ClipboardStore.shared
    @State private var hoveredID: UUID? = nil
    @State private var copiedID: UUID? = nil
    @State private var showClearConfirm = false

    var body: some View {
        ZStack {
            // Background
            Color(NSColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                Divider()
                    .background(Color.white.opacity(0.08))

                // List
                if store.items.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(Array(store.items.enumerated()), id: \.element.id) { index, item in
                                ClipboardRow(
                                    item: item,
                                    index: index,
                                    isHovered: hoveredID == item.id,
                                    isCopied: copiedID == item.id,
                                    onHover: { hoveredID = $0 ? item.id : nil },
                                    onPaste: { handlePaste(item: item) },
                                    onDelete: { store.delete(item: item) }
                                )
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.08))

                // Footer
                footerView
            }
        }
        .frame(width: 380, height: 520)
        .alert("清除所有记录", isPresented: $showClearConfirm) {
            Button("取消", role: .cancel) {}
            Button("清除", role: .destructive) { store.clear() }
        } message: {
            Text("此操作将删除全部 \(store.items.count) 条剪贴板记录，无法恢复。")
        }
    }

    // MARK: - Subviews

    var headerView: some View {
        HStack(alignment: .center) {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(NSColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)))

            Text("剪贴板历史")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Text("\(store.items.count)/10")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.35))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    var footerView: some View {
        HStack {
            Button(action: {
                if !store.items.isEmpty { showClearConfirm = true }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                    Text("清除全部")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(store.items.isEmpty
                    ? Color.white.opacity(0.2)
                    : Color(NSColor(red: 1.0, green: 0.45, blue: 0.45, alpha: 1.0)))
            }
            .buttonStyle(.plain)
            .disabled(store.items.isEmpty)

            Spacer()

            Button(action: { NSApp.terminate(nil) }) {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                        .font(.system(size: 11))
                    Text("退出")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(Color.white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    var emptyStateView: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 36, weight: .thin))
                .foregroundColor(Color.white.opacity(0.15))
            Text("暂无剪贴板记录")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.white.opacity(0.25))
            Text("复制文字或图片后将自动记录在这里")
                .font(.system(size: 11))
                .foregroundColor(Color.white.opacity(0.15))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    func handlePaste(item: ClipboardItem) {
        store.paste(item: item)
        copiedID = item.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            copiedID = nil
        }
    }
}

// MARK: - Row Component

struct ClipboardRow: View {
    let item: ClipboardItem
    let index: Int
    let isHovered: Bool
    let isCopied: Bool
    let onHover: (Bool) -> Void
    let onPaste: () -> Void
    let onDelete: () -> Void

    private let accentColor = Color(NSColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0))

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Index badge
            Text("\(index + 1)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(isHovered ? accentColor : Color.white.opacity(0.2))
                .frame(width: 18, height: 18)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isHovered
                              ? accentColor.opacity(0.15)
                              : Color.white.opacity(0.05))
                )
                .padding(.top, 2)
                .animation(.easeInOut(duration: 0.15), value: isHovered)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                if item.contentType == .image {
                    // 图片预览
                    if let nsImage = item.nsImage {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        // 图片尺寸信息
                        if let sizeText = item.imageSizeText {
                            HStack(spacing: 4) {
                                Image(systemName: "photo")
                                    .font(.system(size: 9))
                                Text(sizeText)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(Color.white.opacity(0.35))
                        }
                    }
                } else {
                    // 文本内容
                    Text(item.preview)
                        .font(.system(size: 12.5, weight: .regular, design: .default))
                        .foregroundColor(Color.white.opacity(0.82))
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }

                Text(item.timeAgo)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.25))
            }

            Spacer()

            // Action buttons
            HStack(spacing: 6) {
                if isHovered {
                    // Delete
                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color.white.opacity(0.4))
                            .frame(width: 22, height: 22)
                            .background(Color.white.opacity(0.07))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }

                // Copy / Copied button
                Button(action: onPaste) {
                    HStack(spacing: 3) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 10, weight: .semibold))
                        Text(isCopied ? "已复制" : "复制")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(isCopied ? .white : accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isCopied
                                  ? Color(NSColor(red: 0.2, green: 0.75, blue: 0.45, alpha: 1.0)).opacity(0.8)
                                  : accentColor.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.25), value: isCopied)
            }
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isHovered
                      ? Color.white.opacity(0.06)
                      : Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isHovered ? accentColor.opacity(0.2) : Color.clear, lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { onHover($0) }
        .onTapGesture(count: 2) { onPaste() }
    }
}
