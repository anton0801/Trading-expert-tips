import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    
    @EnvironmentObject var stocksService: StockService
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Total balance")
                    .font(.custom("Sk-Modernist-Regular", size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top)
                    .padding(.horizontal, 24)
                Text("$\(portfolioManager.balance.formattedToTwoDecimalPlaces())")
                    .font(.custom("Sk-Modernist-Bold", size: 42))
                    .foregroundColor(.white)
                    .padding(.top, 2)
                    .padding(.horizontal, 24)
                
                if !favoritesManager.favorites.isEmpty {
                    Text("Favorites")
                        .font(.custom("Sk-Modernist-Bold", size: 24))
                        .foregroundColor(.white)
                        .padding(.top, 6)
                        .padding(.horizontal, 24)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(favoritesManager.favorites, id: \.id) { favoriteStock in
                                NavigationLink(destination: DetailsView(stockItem: favoriteStock)
                                    .navigationBarBackButtonHidden(true)
                                    .environmentObject(stocksService)
                                    .environmentObject(portfolioManager)
                                    .environmentObject(favoritesManager)
                                ) {
                                    StockItemFavoriteHome(stockItem: favoriteStock)
                                        .environmentObject(stocksService)
                                }
                            }
                        }
                    }
                }
                
                Text("Popular Stocks")
                    .font(.custom("Sk-Modernist-Bold", size: 24))
                    .foregroundColor(.white)
                    .padding(.top, 6)
                    .padding(.horizontal, 24)
                
                ForEach(stocksService.stockItems.filter { !$0.ticker.isEmpty }.sorted(by: { $0.marketCap > $1.marketCap }), id: \.id) { stockItem in
                    NavigationLink(destination: DetailsView(stockItem: stockItem)
                        .navigationBarBackButtonHidden(true)
                        .environmentObject(stocksService)
                        .environmentObject(portfolioManager)
                        .environmentObject(favoritesManager)) {
                            StockItemView(stockItem: stockItem)
                                .environmentObject(stocksService)
                        }
                }
                .padding(.horizontal, 24)
                
                HStack {
                    Spacer()
                }
                .frame(height: 100)
            }
        }
        .background(
            Image("visual")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(StockService())
        .environmentObject(PortfolioManager())
        .environmentObject(FavoritesManager())
}


struct StockItemView: View {
    
    var stockItem: StockItem
    @EnvironmentObject var stocksManager: StockService
    
    var body: some View {
        HStack {
            WebImage(url: URL(string: "\(stockItem.branding.iconUrl)?apiKey=\(APIConfig.apiKey)"))
                .resizable()
                .frame(width: 52, height: 52)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(52)
            
            Text(stockItem.name)
                .font(.custom("Sk-Modernist-Regular", size: 14))
                .foregroundColor(.white)
                .padding(.leading, 4)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            let openClosePrices = stocksManager.stockPrices.filter { $0.symbol == stockItem.ticker }[0]
            
            if openClosePrices.preMarketChangePercentage > 0 {
                Image("stock_up")
                    .resizable()
                    .frame(width: 90, height: 50)
            } else {
                Image("stock_down")
                    .resizable()
                    .frame(width: 90, height: 50)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(openClosePrices.preMarket.formattedToTwoDecimalPlaces())")
                    .font(.custom("Sk-Modernist-Bold", size: 15))
                    .foregroundColor(.white)
                if openClosePrices.preMarketChangePercentage > 0 {
                    Text("+\(openClosePrices.preMarketChangePercentage.formattedToTwoDecimalPlaces())%")
                        .font(.custom("Sk-Modernist-Regular", size: 11))
                        .padding(.top, 2)
                        .foregroundColor(Color.init(red: 33/255, green: 191/255, blue: 115/255))
                } else {
                    Text("\(openClosePrices.preMarketChangePercentage.formattedToTwoDecimalPlaces())%")
                        .font(.custom("Sk-Modernist-Regular", size: 11))
                        .padding(.top, 2)
                        .foregroundColor(Color.init(red: 217/255, green: 4/255, blue: 41/255))
                }
            }
        }
        .padding(.bottom)
    }
    
}

struct StockItemFavoriteHome: View {
    
    var stockItem: StockItem
    @EnvironmentObject var stocksManager: StockService
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                WebImage(url: URL(string: "\(stockItem.branding.iconUrl)?apiKey=\(APIConfig.apiKey)"))
                    .resizable()
                    .frame(width: 52, height: 52)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(52)
                
                Text(stockItem.name)
                    .font(.custom("Sk-Modernist-Regular", size: 15))
                    .foregroundColor(.white)
                    .padding(.leading, 2)
            }
            
            let openClosePrices = stocksManager.stockPrices.filter { $0.symbol == stockItem.ticker }[0]

            Text("$\(openClosePrices.preMarket.formattedToTwoDecimalPlaces())")
                .font(.custom("Sk-Modernist-Bold", size: 15))
                .foregroundColor(.white)
            if openClosePrices.preMarketChangePercentage > 0 {
                Text("+\(openClosePrices.preMarketChangePercentage.formattedToTwoDecimalPlaces())%")
                    .font(.custom("Sk-Modernist-Regular", size: 11))
                    .padding(.top, 2)
                    .foregroundColor(Color.init(red: 33/255, green: 191/255, blue: 115/255))
                
                Image("favorites_up")
                    .resizable()
                    .frame(width: 90, height: 50)
            } else {
                Text("\(openClosePrices.preMarketChangePercentage.formattedToTwoDecimalPlaces())%")
                    .font(.custom("Sk-Modernist-Regular", size: 11))
                    .padding(.top, 2)
                    .foregroundColor(Color.init(red: 217/255, green: 4/255, blue: 41/255))
                
                Image("favorites_down")
                    .resizable()
                    .frame(width: 90, height: 50)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.2))
                .blur(radius: 100)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
        .padding(.trailing, 2)
        .frame(width: 200, height: 180)
    }
    
}
