import SwiftUI

struct ScriptView: View {
    @State var log: String = "running script..."
    let script: (@escaping (String) -> Void) -> Void
    
    var body: some View {
        Text(verbatim: log)
            .onAppear {
                self.script { self.$log.value.append("\n" + $0) }
        }
        .lineLimit(nil)
        .previewLayout(.sizeThatFits)
    }
}
