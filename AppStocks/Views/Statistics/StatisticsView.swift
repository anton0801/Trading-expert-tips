import SwiftUI

struct StatisticsView: View {

    @EnvironmentObject var stocksService: StockService
    @EnvironmentObject var portfolioManager: PortfolioManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        ScrollView(showsIndicators: false) {
           VStack(alignment: .leading) {
               Text("Statistics")
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
    StatisticsView()
        .environmentObject(StockService())
        .environmentObject(PortfolioManager())
        .environmentObject(FavoritesManager())
}
