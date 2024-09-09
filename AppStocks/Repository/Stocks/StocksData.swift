import Combine
import Foundation

struct APIConfig {
    static let apiKey = "R2mp0YV3NRlehS447wz7INWEV6jfQzpP"
    static let baseUrl = "https://api.polygon.io/"
}

class StockService: ObservableObject {
    
    private var cancellableSet = Set<AnyCancellable>()
    
    @Published var stockItems: [StockItem] = []
    @Published var stockPrices: [OpenCloseResponse] = []
    @Published var isLoading: Bool = true
    @Published var error: Error?
    @Published var loadingProgress = 0
    var timer = Timer()
    
    private let tickerList: [String] = [
        "MSFT", "UPS", "AAA", "ABT", "IBM", "ACN", "ADDYY", "AIG", "ALLE", "AMZN", "AAL", "ARMK",
        "CNC", "CVS", "DARDEN", "LMT", "DAL", "F", "GM", "GDDY", "GME", "GOOG", "GRUB",
        "T", "TJX", "TM", "TRIP", "TSLA", "AAPL", "ADS", "AT&T", "BAX", "BDX", "B", "BXS", "BEST",
        "BBY", "LOW", "LYFT", "MMM", "MCD", "META", "MAR", "NKE", "NFLX", "NOC", "ORCL",
        "PEP", "PG", "POST", "PM", "PSTG", "PXD", "RCL", "RTX", "RIVN", "SPG",
        "HES", "HBI", "HCA", "HD", "HRB", "HON", "JCI", "JPM", "JNJ", "K", "KSS", "KR", "LKQ",
        "UNP", "UPS", "V", "VLO", "VZ", "WMT", "XOM", "YUM"
    ]
    
    init() {
        timer = .scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { _ in
            if self.loadingProgress < 90 {
                self.loadingProgress += 1
            }
        })
    }
    
    deinit {
        timer.invalidate()
    }
    
    func loadStockData() {
        isLoading = true
        let tickerBatches = divideTickersIntoBatches(tickerList, size: 20)
        
        let detailsPublishers = tickerBatches.map(fetchDetailsForBatch)
        let pricePublishers = tickerBatches.map(fetchPricesForBatch)
        
        processPublishers(publishers: detailsPublishers) { [weak self] items in
            self?.stockItems = items
        }
        
        processPublishers(publishers: pricePublishers) { [weak self] prices in
            self?.stockPrices = prices
            self?.isLoading = false
        }
    }
    
    private func processPublishers<T>(publishers: [AnyPublisher<[T], Never>], completion: @escaping ([T]) -> Void) {
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { result in
                let mergedResult = result.flatMap { $0 }
                completion(mergedResult)
            })
            .store(in: &cancellableSet)
    }
    
    private func divideTickersIntoBatches(_ tickers: [String], size: Int) -> [[String]] {
        stride(from: 0, to: tickers.count, by: size).map { Array(tickers[$0..<min($0 + size, tickers.count)]) }
    }
    
    private func fetchDetailsForBatch(tickers: [String]) -> AnyPublisher<[StockItem], Never> {
        let publishers = tickers.map(fetchStockDetail)
        return combinePublishers(publishers)
    }
    
    private func fetchPricesForBatch(tickers: [String]) -> AnyPublisher<[OpenCloseResponse], Never> {
        let publishers = tickers.map(fetchStockPrice)
        return combinePublishers(publishers)
    }
    
    private func fetchStockDetail(ticker: String) -> AnyPublisher<StockItem, Never> {
        guard let url = URL(string: "\(APIConfig.baseUrl)v3/reference/tickers/\(ticker)?apiKey=\(APIConfig.apiKey)") else {
            print("Error: Invalid URL for ticker \(ticker)")
            return Just(StockItem.empty).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: StockDetailsResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .catch { error -> Just<StockItem> in
                print("Error decoding StockItem for \(ticker):", error)
                return Just(StockItem.empty)
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchStockPrice(ticker: String) -> AnyPublisher<OpenCloseResponse, Never> {
        let dateString = formattedDateForPreviousDay()
        let url = buildURL(for: "v1/open-close/\(ticker)/\(dateString)", apiKey: APIConfig.apiKey)
        return fetchData(url: url, defaultValue: OpenCloseResponse.empty)
    }
    
    private func buildURL(for path: String, apiKey: String) -> URL? {
        URL(string: "\(APIConfig.baseUrl)\(path)?apiKey=\(apiKey)")
    }
    
    private func fetchData<T: Decodable>(url: URL?, defaultValue: T) -> AnyPublisher<T, Never> {
        guard let url = url else {
            return Just(defaultValue).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .replaceError(with: defaultValue)
            .eraseToAnyPublisher()
    }
    
    private func combinePublishers<T>(_ publishers: [AnyPublisher<T, Never>]) -> AnyPublisher<[T], Never> {
        Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
    }
    
    private func formattedDateForPreviousDay() -> String {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())
        return DateFormatter.yyyyMMdd.string(from: yesterday ?? Date())
    }
}

// Вспомогательные расширения и структуры

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension StockItem {
    static let empty = StockItem(
        ticker: "", name: "", market: "", locale: "",
        primaryExchange: "", type: "", marketCap: 0.0,
        phoneNumber: "", description: "", homepageUrl: "",
        branding: Branding(logoUrl: "", iconUrl: "")
    )
}

extension OpenCloseResponse {
    static let empty = OpenCloseResponse(
        symbol: "", open: 0.0, high: 0.0, low: 0.0,
        volume: 0, preMarket: 0.0
    )
}
