import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab: Int = 0
    @EnvironmentObject var stocksService: StockService
    
    @StateObject var porfolioManager: PortfolioManager = PortfolioManager()
    @StateObject var favoritesManager: FavoritesManager = FavoritesManager()
    
    var body: some View {
        ZStack {
            
            switch selectedTab {
                case 0:
                    HomeView()
                        .environmentObject(stocksService)
                        .environmentObject(porfolioManager)
                        .environmentObject(favoritesManager)
                case 1:
                    StatisticsView()
                        .environmentObject(stocksService)
                        .environmentObject(porfolioManager)
                        .environmentObject(favoritesManager)
                case 2:
                    FavoritesView()
                        .environmentObject(stocksService)
                        .environmentObject(porfolioManager)
                        .environmentObject(favoritesManager)
                case 3:
                    AssetsStocksView()
                        .environmentObject(stocksService)
                        .environmentObject(porfolioManager)
                        .environmentObject(favoritesManager)
                default:
                    EmptyView()
                }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    // Домашняя вкладка
                    TabBarButton(iconName: "home", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }

                    Spacer()

                    // Аналитика
                    TabBarButton(iconName: "statistics", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }

                    Spacer()

                    // Избранное
                    TabBarButton(iconName: "favorites", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }

                    Spacer()

                    // Кошелек
                    TabBarButton(iconName: "wallet", isSelected: selectedTab == 3) {
                        selectedTab = 3
                    }

                    Spacer()
                }
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.white.opacity(0.3))
                        .blur(radius: 50)
                )
                // .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(
            Image("visual")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
        .preferredColorScheme(.dark)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct TabBarButton: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(iconName)
                    .resizable()
                    .frame(width: 26, height: 26)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(isSelected ? Color.blue : Color.gray)
                    .foregroundColor(isSelected ? Color.blue : Color.gray)
                    .padding()
                
                if isSelected {
                    Image("selected_line")
                        .resizable()
                        .frame(width: 50, height: 2)
                        .offset(y: -5)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StockService())
}
