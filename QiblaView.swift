//
//  QiblaView.swift
//  Arkan
//
//  Created by mac on 2/2/25.
//

import SwiftUI

struct QiblaView: View{
    
    var body: some View{
        NavigationView{
            VStack{
                Text("Qibla Direction")
                    .font(.headline)
                Image(systemName: "location.north.circle.fill")
                    .resizable()
                    .frame(width:200, height: 200)
                    .foregroundStyle(.green)
                    .rotationEffect(.degrees(45))
                    .animation(.spring().repeatForever(autoreverses: false), value: UUID())
            }
            .navigationTitle("Qibla")
        }
    }
}



struct  QiblaView_provider: PreviewProvider{
    static var previews: some View {
        QiblaView()
    }
}
