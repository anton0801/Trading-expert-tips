import SwiftUI
import Combine

struct PortfolioItem: Codable, Identifiable {
    let id = UUID().uuidString
    let ticker: String
    var quantity: Int
}

class PortfolioManager: ObservableObject {
    @Published private(set) var portfolio: [PortfolioItem] = [] {
        didSet {
            savePortfolio()
        }
    }
    @Published private(set) var balance: Double = 0.0 {
        didSet {
            saveBalance()
        }
    }

    private let portfolioKey = "portfolioKey"
    private let balanceKey = "balanceKey"

    init() {
        loadPortfolio()
        loadBalance()
    }

    // Метод покупки акции
    func buy(ticker: String, price: Double, quantity: Int) {
        let totalPrice = quantity

        // Если акция уже есть в портфеле, просто увеличиваем количество
        if let index = portfolio.firstIndex(where: { $0.ticker == ticker }) {
            portfolio[index].quantity += quantity
        } else {
            let newStock = PortfolioItem(ticker: ticker, quantity: quantity)
            portfolio.append(newStock)
        }
        
        // Обновляем баланс
        updateBalance(with: Double(totalPrice))
    }

    // Метод продажи акции
    func sell(ticker: String, price: Double, quantity: Int) {
        if let index = portfolio.firstIndex(where: { $0.ticker == ticker }) {
            let currentQuantity = portfolio[index].quantity
            let totalPrice = Double(quantity)

            // Проверяем, можно ли продать запрашиваемое количество акций
            if currentQuantity >= quantity {
                portfolio[index].quantity -= quantity
                
                // Если все акции проданы, удаляем их из портфеля
                if portfolio[index].quantity == 0 {
                    portfolio.remove(at: index)
                }
                
                // Обновляем баланс
                updateBalance(with: -totalPrice)
            } else {
                print("Error: Not enough shares to sell")
            }
        }
    }

    private func updateBalance(with transactionAmount: Double) {
        balance += transactionAmount
    }

    // Сохранение портфеля в UserDefaults
    private func savePortfolio() {
        if let encoded = try? JSONEncoder().encode(portfolio) {
            UserDefaults.standard.set(encoded, forKey: portfolioKey)
        }
    }

    // Загрузка портфеля из UserDefaults
    private func loadPortfolio() {
        if let savedData = UserDefaults.standard.data(forKey: portfolioKey),
           let decoded = try? JSONDecoder().decode([PortfolioItem].self, from: savedData) {
            self.portfolio = decoded
        }
    }

    // Сохранение баланса в UserDefaults
    private func saveBalance() {
        UserDefaults.standard.set(balance, forKey: balanceKey)
    }

    // Загрузка баланса из UserDefaults
    private func loadBalance() {
        balance = UserDefaults.standard.double(forKey: balanceKey)
    }
}

