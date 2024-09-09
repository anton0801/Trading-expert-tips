import SwiftUI

struct AssetsStocksView: View {
    
    @EnvironmentObject var stocksService: StockService
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State var stocks: [StockItem] = []
    @State var totalPrice: Double = 0.00
    @State var percentChange: Double = 0.00
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total balance")
                                .font(.custom("Sk-Modernist-Regular", size: 16))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.top)
                                .padding(.horizontal, 24)
                            Text("\(portfolioManager.balance.formattedToTwoDecimalPlaces()) $")
                                .font(.custom("Sk-Modernist-Bold", size: 32))
                                .foregroundColor(.white)
                                .padding(.top, 2)
                                .padding(.horizontal, 24)
                        }
                        Spacer()
                        Text(percentChange > 0 ? "+\(percentChange.formattedToTwoDecimalPlaces())%" : "\(percentChange.formattedToTwoDecimalPlaces())%").font(.custom("Sk-Modernist-Regular", size: 18))
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(.white.opacity(0.3))
                                    .blur(radius: 2)
                            )
                        
                    }
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 32, trailing: 16))
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.white.opacity(0.3))
                            .blur(radius: 2)
                    )
                    .frame(width: 360)
                    
                    VStack(alignment: .leading) {
                        Text("Today profit")
                            .font(.custom("Sk-Modernist-Regular", size: 16))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top)
                            .padding(.horizontal, 24)
                        Text("\(((totalPrice / 100) * percentChange).formattedToTwoDecimalPlaces()) $")
                            .font(.custom("Sk-Modernist-Bold", size: 24))
                            .foregroundColor(.white)
                            .padding(.top, 2)
                            .padding(.horizontal, 24)
                        
                        HStack {
                            Spacer()
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 12))
                    .background(
                        Image("rs")
                            .resizable()
                            .frame(width: 360)
                    )
                    .offset(y: -25)
                }
            }
            .padding(.horizontal)
        }
        .background(
            Image("visual")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
        .onAppear {
            calculateTotalPrice()
        }
    }
    
    func calculateTotalPrice() {
        for portfolioItem in portfolioManager.portfolio {
            if let stock = stocksService.stockItems.filter({ $0.ticker == portfolioItem.ticker }).first {
                self.stocks.append(stock)
            }
        }
        
        for stock in stocks {
            let openClosePrices = stocksService.stockPrices.filter { $0.symbol == stock.ticker }[0]
            totalPrice += openClosePrices.preMarket
            percentChange += openClosePrices.preMarketChangePercentage
        }
    }
    
    
}

#Preview {
    AssetsStocksView()
        .environmentObject(StockService())
        .environmentObject(PortfolioManager())
        .environmentObject(FavoritesManager())
}
