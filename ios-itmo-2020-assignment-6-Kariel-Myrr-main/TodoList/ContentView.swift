import SwiftUI
import Combine

struct TodoListView: View {
    @StateObject var viewModel = TodoListViewModel()
    @State var list : [ToDoCellData] = []
    @State var content = ""
    
    func chageData() -> Void{
        list[0].flag = false
    }
    
    var body: some View {
        VStack{
            HStack{
                TextField("edit", text: $content)
                Button("+", action: {
                    list.append(ToDoCellData(content: "\(content)"))
                }).buttonStyle(NeumorphicButtonStyle(bgColor: .green))
            }.background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.gray)).previewLayout(.sizeThatFits)
            NavigationView{
                List(list){ todo in
                    ToDoCellView(data: todo)
                }
            }.buttonStyle(BorderlessButtonStyle())
            ZStack{
                Button("clear", action: {
                    var i = 0;
                    while i < list.count {
                        if(list[i].flag){
                            i+=1
                        } else {
                            list.remove(at: i)
                        }
                    }
                }).buttonStyle(NeumorphicButtonStyle(bgColor: .red))
            }
        }
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    var bgColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(bgColor)
                }
        )
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .foregroundColor(.primary)
            .animation(.spring())
    }
}

class ToDoCellData : Identifiable, ObservableObject{
    let id = UUID()
    let content : String
    @Published var flag : Bool
    
    init(content : String) {
        self.content = content
        flag = true
    }
}

struct ToDoCellView : View{
    
    @StateObject var data : ToDoCellData
    
    
    var body: some View {
        HStack{
            if(data.flag){
                Text("ToDo: \(data.content)").foregroundColor(.black)
                Spacer(minLength: 3)
                Button("done", action: {
                    data.flag = false
                })
            } else {
                Text("Done: \(data.content)").foregroundColor(.gray)
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}

//Identifiable
