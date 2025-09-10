//
//  LazyLoadingComponents.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import Combine

/// High-performance lazy loading components
public struct LazyLoadingList<Item: Identifiable, Content: View>: View {
    // MARK: - Properties
    
    let items: [Item]
    let itemContent: (Item) -> Content
    let loadMore: () -> Void
    let isLoading: Bool
    let hasMore: Bool
    
    // MARK: - Constants
    
    private let loadMoreThreshold = 5
    
    // MARK: - Initialization
    
    public init(
        items: [Item],
        isLoading: Bool = false,
        hasMore: Bool = true,
        loadMore: @escaping () -> Void = {},
        @ViewBuilder itemContent: @escaping (Item) -> Content
    ) {
        self.items = items
        self.itemContent = itemContent
        self.loadMore = loadMore
        self.isLoading = isLoading
        self.hasMore = hasMore
    }
    
    // MARK: - Body
    
    public var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(items) { item in
                itemContent(item)
                    .onAppear {
                        if shouldLoadMore(for: item) {
                            loadMore()
                        }
                    }
            }
            
            if isLoading {
                LoadingIndicator()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func shouldLoadMore(for item: Item) -> Bool {
        guard hasMore && !isLoading else { return false }
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            return index >= items.count - loadMoreThreshold
        }
        
        return false
    }
}

/// Lazy loading grid component
public struct LazyLoadingGrid<Item: Identifiable, Content: View>: View {
    // MARK: - Properties
    
    let items: [Item]
    let columns: [GridItem]
    let itemContent: (Item) -> Content
    let loadMore: () -> Void
    let isLoading: Bool
    let hasMore: Bool
    
    // MARK: - Constants
    
    private let loadMoreThreshold = 10
    
    // MARK: - Initialization
    
    public init(
        items: [Item],
        columns: [GridItem],
        isLoading: Bool = false,
        hasMore: Bool = true,
        loadMore: @escaping () -> Void = {},
        @ViewBuilder itemContent: @escaping (Item) -> Content
    ) {
        self.items = items
        self.columns = columns
        self.itemContent = itemContent
        self.loadMore = loadMore
        self.isLoading = isLoading
        self.hasMore = hasMore
    }
    
    // MARK: - Body
    
    public var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(items) { item in
                itemContent(item)
                    .onAppear {
                        if shouldLoadMore(for: item) {
                            loadMore()
                        }
                    }
            }
            
            if isLoading {
                LoadingIndicator()
                    .gridCellColumns(columns.count)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func shouldLoadMore(for item: Item) -> Bool {
        guard hasMore && !isLoading else { return false }
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            return index >= items.count - loadMoreThreshold
        }
        
        return false
    }
}

/// Lazy loading image component
public struct LazyLoadingImage: View {
    // MARK: - Properties
    
    let url: URL?
    let placeholder: Image
    let contentMode: ContentMode
    
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var hasError = false
    
    // MARK: - Initialization
    
    public init(
        url: URL?,
        placeholder: Image = Image(systemName: "photo"),
        contentMode: ContentMode = .fit
    ) {
        self.url = url
        self.placeholder = placeholder
        self.contentMode = contentMode
    }
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .clipped()
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if hasError {
                placeholder
                    .foregroundColor(.gray)
            } else {
                placeholder
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        // Check cache first
        if let cachedImage = CacheManager.shared.getCachedImage(forKey: url.absoluteString) {
            image = cachedImage
            return
        }
        
        isLoading = true
        hasError = false
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                await MainActor.run {
                    if let loadedImage = UIImage(data: data) {
                        image = loadedImage
                        CacheManager.shared.cacheImage(loadedImage, forKey: url.absoluteString)
                    } else {
                        hasError = true
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    hasError = true
                    isLoading = false
                }
            }
        }
    }
}

/// Lazy loading content component
public struct LazyLoadingContent<Content: View, Placeholder: View>: View {
    // MARK: - Properties
    
    let content: () -> Content
    let placeholder: () -> Placeholder
    let loadTrigger: AnyPublisher<Void, Never>
    
    @State private var isLoaded = false
    @State private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(
        loadTrigger: AnyPublisher<Void, Never>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.content = content
        self.placeholder = placeholder
        self.loadTrigger = loadTrigger
    }
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            if isLoaded {
                content()
            } else {
                placeholder()
            }
        }
        .onAppear {
            loadTrigger
                .sink { _ in
                    withAnimation {
                        isLoaded = true
                    }
                }
                .store(in: &cancellables)
        }
    }
}

/// Loading indicator component
public struct LoadingIndicator: View {
    // MARK: - Properties
    
    let style: LoadingStyle
    let size: CGFloat
    
    // MARK: - Initialization
    
    public init(
        style: LoadingStyle = .spinner,
        size: CGFloat = 20
    ) {
        self.style = style
        self.size = size
    }
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            switch style {
            case .spinner:
                ProgressView()
                    .scaleEffect(size / 20)
            case .dots:
                DotsLoadingView(size: size)
            case .pulse:
                PulseLoadingView(size: size)
            }
        }
        .frame(width: size, height: size)
    }
}

/// Loading styles
public enum LoadingStyle {
    case spinner
    case dots
    case pulse
}

/// Dots loading animation
private struct DotsLoadingView: View {
    let size: CGFloat
    
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: size / 4, height: size / 4)
                    .offset(y: animationOffset)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            animationOffset = -size / 4
        }
    }
}

/// Pulse loading animation
private struct PulseLoadingView: View {
    let size: CGFloat
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .animation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
                value: scale
            )
            .onAppear {
                scale = 0.5
            }
    }
}

/// Pagination view model
@MainActor
public class PaginationViewModel<Item: Identifiable>: ObservableObject {
    // MARK: - Published Properties
    
    @Published public var items: [Item] = []
    @Published public var isLoading = false
    @Published public var hasMore = true
    @Published public var error: Error?
    
    // MARK: - Private Properties
    
    private let pageSize: Int
    private let loadItems: (Int, Int) async throws -> [Item]
    private var currentPage = 0
    
    // MARK: - Initialization
    
    public init(
        pageSize: Int = 20,
        loadItems: @escaping (Int, Int) async throws -> [Item]
    ) {
        self.pageSize = pageSize
        self.loadItems = loadItems
    }
    
    // MARK: - Public Methods
    
    public func loadFirstPage() async {
        await loadPage(0)
    }
    
    public func loadNextPage() async {
        guard !isLoading && hasMore else { return }
        await loadPage(currentPage + 1)
    }
    
    public func refresh() async {
        items.removeAll()
        currentPage = 0
        hasMore = true
        await loadFirstPage()
    }
    
    // MARK: - Private Methods
    
    private func loadPage(_ page: Int) async {
        isLoading = true
        error = nil
        
        do {
            let newItems = try await loadItems(page, pageSize)
            
            if page == 0 {
                items = newItems
            } else {
                items.append(contentsOf: newItems)
            }
            
            currentPage = page
            hasMore = newItems.count == pageSize
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
