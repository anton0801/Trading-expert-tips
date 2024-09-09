import SwiftUI

struct BuySellView: View {
    
    var isBuy: Bool
    @Environment(\.presentationMode) var presMode
    @EnvironmentObject var stocksManager: StockService
    @EnvironmentObject var favoriteManager: FavoritesManager
    @EnvironmentObject var porfolioManger: PortfolioManager
    var stockItem: StockItem
    @State var sum = "0"
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    presMode.wrappedValue.dismiss()
                } label: {
                    Image("back_btn")
                        .resizable()
                        .frame(width: 42, height: 42)
                }
                
                Spacer()
                
                Text(isBuy ? "Buy \(stockItem.name)" : "Sell \(stockItem.name)")
                       .font(.custom("Sk-Modernist-Bold", size: 18))
                       .foregroundColor(.white)
                       .padding(.leading, 4)
                       .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal)
            
            TextField("", text: $sum)
                .font(.custom("Sk-Modernist-Bold", size: 72))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 92)
                .keyboardType(.decimalPad)
            
            let openClosePrices = stocksManager.stockPrices.filter { $0.symbol == stockItem.ticker }[0]
            Text("Min - \(openClosePrices.preMarket.formattedToTwoDecimalPlaces())")
                   .font(.custom("Sk-Modernist-Bold", size: 18))
                   .foregroundColor(.white)
                   .padding(.leading, 4)
                   .multilineTextAlignment(.leading)
                
            Spacer()
            
            if isBuy {
                Button {
                    if !sum.isEmpty {
                        let sumNum = Int(sum)
                        porfolioManger.buy(ticker: stockItem.ticker, price: openClosePrices.preMarket, quantity: sumNum ?? 0)
                        presMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Buy")
                        .font(.custom("Sk-Modernist-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.init(red: 2/255, green: 193/255, blue: 113/255))
                        )
                        .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                }
            } else {
                Button {
                    if !sum.isEmpty {
                        let sumNum = Int(sum)
                        porfolioManger.sell(ticker: stockItem.ticker, price: openClosePrices.preMarket, quantity: sumNum ?? 0)
                        presMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Sell")
                        .font(.custom("Sk-Modernist-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.init(red: 225/255, green: 26/255, blue: 56/255))
                        )
                        .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                }
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
    BuySellView(isBuy: false, stockItem: .empty)
        .environmentObject(FavoritesManager())
        .environmentObject(PortfolioManager())
        .environmentObject(StockService())
}
