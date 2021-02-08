//
//  ContentView.swift
//  nfcbug
//
//  Created by Dusan Klinec on 30/09/2020.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    private var nfc = Nfc()
    private var nfcClosePoc = NfcClosePoc()
    private var nfcDemo = NfcDemo()
    @State var txt: String = ""

    var body: some View {
        Spacer(minLength: 20.0)
        
        Button(action: startNfc) {
            Label(" Start NFC test: Open race", systemImage: "play")
        }
        
        Spacer(minLength: 20.0)
        
        Button(action: startNfcClosePoC) {
            Label(" Start NFC test: Close race", systemImage: "play")
        }
        
        Spacer(minLength: 20.0)
        Button(action: simpleOpen) {
            Label(" Open NFC session", systemImage: "play")
        }
        
        
        TextEditor(text: $txt)
            .lineLimit(10)
            .font(.subheadline)
        
        List {
            ForEach(items) { item in
                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            EditButton()
            Button(action: addItem) {
                Label("Add Item", systemImage: "plus")
            }
        }
    }
    
    mutating func setTxt(_ txt: String){
        self.txt = txt
    }
    
    private func startNfc() {
        nfc.cv = self
        nfc.startNfc()
    }

    private func startNfcClosePoC() {
        nfcClosePoc.cv = self
        nfcClosePoc.startNfc()
    }
    
    private func simpleOpen() {
        nfcDemo.cv = self
        nfcDemo.startNfc()
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
