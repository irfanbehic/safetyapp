import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text(LocalizedStringKey("app_title"))
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                TextField(LocalizedStringKey("search_placeholder"), text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing])
                
                Spacer()
                // Map placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 350)
                    .overlay(Text("[MapKit Haritası Burada]").foregroundColor(.gray))
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}