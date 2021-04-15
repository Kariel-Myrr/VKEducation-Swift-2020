//
//  ToDoEditorView.swift
//  TodoList
//
//  Created by Kariel Myrr on 08.01.2021.
//

import SwiftUI

struct ToDoEditorView : View {
    
    @State var content = ""
    
    var body: some View {
        HStack{
            TextField("edit", text: $content)
            Button("add", action: {})
        }
    }
    
}
