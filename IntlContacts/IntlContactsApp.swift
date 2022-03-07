import SwiftUI

@main
struct IntlContactsApp: App {
    static func main() {
        ContactsManager.internationalizeContacts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
