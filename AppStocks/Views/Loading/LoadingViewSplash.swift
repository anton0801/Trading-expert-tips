import SwiftUI

struct LoadingViewSplash: View {
    
    @StateObject var stocksService = StockService()
    @State var dataLoaded = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Image("logo")
                    .resizable()
                    .frame(width: 200, height: 200)
                
                Spacer()
                
                Text("LOADING...")
                    .font(.custom("Sk-Modernist-Bold", size: 32))
                    .foregroundColor(Color.init(red: 126/255, green: 123/255, blue: 1))
                
                ZStack(alignment: .leading) {
                    Image("loading_back")
                        .resizable()
                        .frame(width: 300, height: 20)
                    
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(LinearGradient(colors: [Color.init(red: 17/255, green: 252/255, blue: 210/255), Color.init(red: 126/255, green: 123/255, blue: 1)], startPoint: .bottomLeading, endPoint: .topTrailing))
                        .frame(width: CGFloat(stocksService.loadingProgress) * (300.0 / 100.0), height: 20)
                }
                
                if !stocksService.isLoading {
                    Text("")
                        .onAppear {
                            stocksService.loadingProgress = 100
                            dataLoaded = true
                        }
                }
                
                NavigationLink(destination: ContentView()
                    .navigationBarBackButtonHidden(true)
                    .environmentObject(stocksService), isActive: $dataLoaded) {
                    
                }
            }
            .background(
                Image("visual")
                    .resizable()
                    .frame(minWidth: UIScreen.main.bounds.width,
                           minHeight: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
            )
            .onAppear {
                stocksService.loadStockData()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    LoadingViewSplash()
}
