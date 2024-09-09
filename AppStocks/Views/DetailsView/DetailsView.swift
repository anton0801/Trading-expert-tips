import SwiftUI
import WebKit

struct DetailsView: View {
    
    @Environment(\.presentationMode) var presMode
    @EnvironmentObject var stocksManager: StockService
    @EnvironmentObject var favoriteManager: FavoritesManager
    @EnvironmentObject var porfolioManger: PortfolioManager
    var stockItem: StockItem
    var htmlString: String {
            return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body, html {
                        margin: 0;
                        padding: 0;
                        height: 100%;
                        width: 100%;
                        overflow: hidden;
                        background: #161514;
                    }
                    .tradingview-widget-container {
                        position: absolute;
                        top: 0;
                        left: 0;
                        right: 0;
                        bottom: 0;
                        height: 100%;
                        width: 100%;
                    }
                </style>
            </head>
            <body>
                <div class="tradingview-widget-container">
                    <div id="tradingview_\(stockItem.ticker)"></div>
                    <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
                    <script type="text/javascript">
                    new TradingView.widget({
                    "width": "100%",
                                      "height": "100%",
                      "symbol": "\(stockItem.ticker)",
                      "interval": "D",
                      "timezone": "Etc/UTC",
                      "theme": "dark",
                      "style": "1",
                      "locale": "en",
                      "toolbar_bg": "#f1f3f6",
                      "hide_top_toolbar": true, // Скрываем верхнюю панель
                      "hide_legend": true,      // Скрываем легенду
                      "save_image": false,
                      "studies": [],
                      "hidevolume": true,       // Скрываем объём
                      "container_id": "tradingview_\(stockItem.ticker)"
                    });
                    </script>
                </div>
            </body>
            </html>
            """
        }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    presMode.wrappedValue.dismiss()
                } label: {
                    Image("back_btn")
                        .resizable()
                        .frame(width: 42, height: 42)
                }
                
                Spacer()
                
                Text(stockItem.name)
                       .font(.custom("Sk-Modernist-Bold", size: 18))
                       .foregroundColor(.white)
                       .padding(.leading, 4)
                       .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button {
                    withAnimation {
                        if favoriteManager.isFavorite(stock: stockItem) {
                            favoriteManager.removeFromFavorites(stock: stockItem)
                        } else {
                            favoriteManager.addToFavorites(stock: stockItem)
                        }
                    }
                } label: {
                    if favoriteManager.isFavorite(stock: stockItem) {
                        Image("favorite_on")
                            .resizable()
                            .frame(width: 42, height: 42)
                    } else {
                        Image("favorite_off")
                            .resizable()
                            .frame(width: 42, height: 42)
                    }
                }
            }
            .padding(.horizontal)
            
            let openClosePrices = stocksManager.stockPrices.filter { $0.symbol == stockItem.ticker }[0]
            // let openClosePrices = OpenCloseResponse.empty
            
            Text("$\(openClosePrices.preMarket.formattedToTwoDecimalPlaces())")
                .font(.custom("Sk-Modernist-Bold", size: 32))
                .foregroundColor(.white)
                .padding(.leading)
            if openClosePrices.preMarketChangePercentage > 0 {
                Text("+\(openClosePrices.preMarketChangePercentage.formattedToTwoDecimalPlaces())%")
                    .font(.custom("Sk-Modernist-Regular", size: 11))
                    .padding(.leading)
                    .foregroundColor(Color.init(red: 33/255, green: 191/255, blue: 115/255))
            } else {
                Text("\(openClosePrices.preMarketChangePercentage.formattedToTwoDecimalPlaces())%")
                    .font(.custom("Sk-Modernist-Regular", size: 16))
                    .padding(.leading)
                    .foregroundColor(Color.init(red: 217/255, green: 4/255, blue: 41/255))
            }
            
            GraphView(htmlString: htmlString)
                .frame(height: 350)
                .padding(.top)
            
            Spacer()
            
            HStack {
                NavigationLink(destination: BuySellView(isBuy: true, stockItem: stockItem)
                    .navigationBarBackButtonHidden(true)
                    .environmentObject(stocksManager)
                    .environmentObject(porfolioManger)
                    .environmentObject(favoriteManager)) {
                    Text("Buy")
                            .font(.custom("Sk-Modernist-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.init(red: 2/255, green: 193/255, blue: 113/255))
                            )
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 4))
                }
                NavigationLink(destination: BuySellView(isBuy: false, stockItem: stockItem)
                    .navigationBarBackButtonHidden(true)
                    .environmentObject(stocksManager)
                    .environmentObject(porfolioManger)
                    .environmentObject(favoriteManager)) {
                    Text("Sell")
                            .font(.custom("Sk-Modernist-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.init(red: 225/255, green: 26/255, blue: 56/255))
                            )
                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 8))
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
    DetailsView(stockItem: .empty)
        .environmentObject(FavoritesManager())
        .environmentObject(PortfolioManager())
        .environmentObject(StockService())
}

struct GraphView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}
