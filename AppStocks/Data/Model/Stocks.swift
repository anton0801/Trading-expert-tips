import Foundation

// Структура для хранения информации о компании (акции)
struct StockItem: Codable, Identifiable {
    let id = UUID().uuidString
    let ticker: String
    let name: String
    let market: String
    let locale: String
    let primaryExchange: String
    let type: String
    let marketCap: Double
    let phoneNumber: String
    let description: String
    let homepageUrl: String
    let branding: Branding
    
    // Упрощаем сериализацию и десериализацию с помощью CodingKeys
    private enum CodingKeys: String, CodingKey {
        case ticker
        case name
        case market
        case locale
        case primaryExchange = "primary_exchange"
        case type
        case marketCap = "market_cap"
        case phoneNumber = "phone_number"
        case description
        case homepageUrl = "homepage_url"
        case branding
    }
}

// Структура для хранения данных о торговых сессиях (открытие/закрытие)
struct OpenCloseResponse: Codable {
    let symbol: String
    let open: Double
    let high: Double
    let low: Double
    let volume: Int
    let preMarket: Double
    
    // Вычисляемое свойство для получения изменения на премаркете в процентах
    var preMarketChangePercentage: Double {
        guard preMarket != 0 else { return 0 } // Защита от деления на 0
        return ((open - preMarket) / preMarket) * 100
    }
}

// Структура для хранения информации о брендинге компании
struct Branding: Codable {
    let logoUrl: String
    let iconUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case logoUrl = "logo_url"
        case iconUrl = "icon_url"
    }
}

// Ответ API для получения подробностей о компании
struct StockDetailsResponse: Codable {
    let results: StockItem
}

// Пример упрощения структуры Branding для однотипного использования
extension StockItem {
    static let placeholder = StockItem(
        ticker: "TICKER",
        name: "Unknown Company",
        market: "Unknown Market",
        locale: "en",
        primaryExchange: "Unknown Exchange",
        type: "Unknown Type",
        marketCap: 0.0,
        phoneNumber: "N/A",
        description: "No description available",
        homepageUrl: "N/A",
        branding: Branding(logoUrl: "", iconUrl: "")
    )
}

// Упрощение создания пустых значений для OpenCloseResponse
extension OpenCloseResponse {
    static let placeholder = OpenCloseResponse(
        symbol: "UNKNOWN",
        open: 0.0,
        high: 0.0,
        low: 0.0,
        volume: 0,
        preMarket: 0.0
    )
}
