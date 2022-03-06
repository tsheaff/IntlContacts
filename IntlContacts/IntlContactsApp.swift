import SwiftUI
import Contacts

@main
struct IntlContactsApp: App {
    static func main() {
        print("hello world")
        PhoneContacts.internationalizeContacts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class PhoneContacts {
    class func internationalizeContacts() {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
        ] as [Any]

        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }

        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                for contact in containerResults {
                    if contact.isKeyAvailable(CNContactPhoneNumbersKey),
                       !contact.phoneNumbers.isEmpty
                    {
                        for phoneNumber: CNLabeledValue in contact.phoneNumbers {
                            print("Contact \(contact.identifier): Phone Number for \(contact.givenName) \(contact.familyName) is \(phoneNumber.value.stringValue)")
                        }
                    }
                }
            } catch {
                print("Error fetching containers")
            }
        }
    }
}
