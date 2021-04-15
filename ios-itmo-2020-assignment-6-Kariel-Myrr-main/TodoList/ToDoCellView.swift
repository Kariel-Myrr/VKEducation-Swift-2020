//
//  ToDoCellView.swift
//  TodoList
//
//  Created by Kariel Myrr on 08.01.2021.
//

import SwiftUI

struct ToDoCellView : View, Identifiable{
    var id = UUID()
    
    var content : String
    
    
    var body: some View {
        HStack{
            Text("ToDo: \(content)")
            Spacer(minLength: 3)
            Button("done", action: {})
        }
    }
    
}

