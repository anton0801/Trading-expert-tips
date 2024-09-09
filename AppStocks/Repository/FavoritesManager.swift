import SwiftUI
import Combine

class FavoritesManager: ObservableObject {
    // Массив для хранения избранных акций
    @Published private(set) var favorites: [StockItem] = [] {
        didSet {
            saveFavorites()
        }
    }
    
    private let userDefaultsKey = "favoritesKey"

    init() {
        loadFavorites()
    }
    
    // Метод для добавления акции в избранное
    func addToFavorites(stock: StockItem) {
        // Проверка, что акции еще нет в избранном
        if !favorites.contains(where: { $0.ticker == stock.ticker }) {
            favorites.append(stock)
        }
    }
    
    // Метод для удаления акции из избранного
    func removeFromFavorites(stock: StockItem) {
        // Удаляем акцию, если она есть в избранном
        if let index = favorites.firstIndex(where: { $0.ticker == stock.ticker }) {
            favorites.remove(at: index)
        }
    }
    
    // Метод для проверки, находится ли акция в избранном
    func isFavorite(stock: StockItem) -> Bool {
        return favorites.contains(where: { $0.ticker == stock.ticker })
    }
    
    // Сохранение состояния в UserDefaults
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    // Загрузка состояния из UserDefaults
    private func loadFavorites() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([StockItem].self, from: savedData) {
            self.favorites = decoded
        }
    }

}
