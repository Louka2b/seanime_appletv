import SwiftUI

struct LibraryGridView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var focusedEntry: AnimeEntry?
    @FocusState private var focusedCard: Int?

    var body: some View {
        ZStack {
            if let banner = focusedEntry?.media?.bannerImage {
                AsyncImage(url: URL(string: banner)) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.clear }
                .frame(maxWidth: .infinity, maxHeight: .infinity).blur(radius: 50).opacity(0.3).edgesIgnoringSafeArea(.all)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 50) {
                    if let lists = viewModel.collection?.lists {
                        ForEach(0..<lists.count, id: \.self) { i in
                            let list = lists[i]
                            if let entries = list.entries, !entries.isEmpty {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text(list.type?.uppercased() ?? "OTHER").font(.system(size: 25, weight: .bold)).foregroundColor(.secondary).padding(.leading, 60)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 30) {
                                            ForEach(0..<entries.count, id: \.self) { j in
                                                let entry = entries[j]
                                                let cardId = (i * 1000) + j
                                                
                                                NavigationLink(destination: AnimeDetailView(entry: entry)) {
                                                    SeanimeCard(entry: entry)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .focused($focusedCard, equals: cardId)
                                                .onFocusChange { isFocused in
                                                    if isFocused {
                                                        focusedEntry = entry
                                                        focusedCard = cardId
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 60)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 80)
            }
        }
        .task {
            await viewModel.fetchLibrary()
            if focusedCard == nil { focusedCard = 0 }
        }
    }
}

struct SeanimeCard: View {
    let entry: AnimeEntry
    @Environment(\.isFocused) var isFocused
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            AsyncImage(url: URL(string: entry.media?.coverImage?.large ?? "")) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.white.opacity(0.1) }
            .frame(width: 220, height: 330).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(isFocused ? .white : .clear, lineWidth: 5))
            Text(entry.media?.title?.userPreferred ?? "").font(.system(size: 20, weight: .bold)).lineLimit(2).frame(width: 220, alignment: .leading).foregroundColor(isFocused ? .white : .secondary)
        }
        .scaleEffect(isFocused ? 1.05 : 1.0).animation(.snappy, value: isFocused)
    }
}

extension View {
    func onFocusChange(perform action: @escaping (Bool) -> Void) -> some View { self.background(FocusObserver(action: action)) }
}

struct FocusObserver: UIViewControllerRepresentable {
    let action: (Bool) -> Void
    func makeUIViewController(context: Context) -> FocusViewController { FocusViewController(action: action) }
    func updateUIViewController(_ uiViewController: FocusViewController, context: Context) {}
}

class FocusViewController: UIViewController {
    let action: (Bool) -> Void
    init(action: @escaping (Bool) -> Void) { self.action = action; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        action(context.nextFocusedView?.isDescendant(of: view) ?? false)
    }
}
