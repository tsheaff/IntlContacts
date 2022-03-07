import Contacts

class ContactsManager {
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
            print("Error fetching containers: \(error)")
        }

        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                for contact in containerResults {
                    let mutableContact = contact.mutableCopy() as! CNMutableContact
                    if contact.isKeyAvailable(CNContactPhoneNumbersKey),
                       !contact.phoneNumbers.isEmpty
                    {
                        for (index, phoneNumber) in mutableContact.phoneNumbers.enumerated() {
                            let labelName = CNLabeledValue<NSString>.localizedString(forLabel: phoneNumber.label ?? "none")
                            print("Contact \(mutableContact.identifier): \(mutableContact.givenName) \(mutableContact.familyName) has `\(labelName)` \(phoneNumber.value.stringValue)")
                            let phoneNumberText = phoneNumber.value.stringValue
                            let alreadyHasCountryCode = phoneNumberText.starts(with: "+")
                            if alreadyHasCountryCode { continue }

                            let numbersOnly = phoneNumberText.filter("0123456789.".contains)
                            if numbersOnly.count != 10 { continue }

                            let usaCCPattern = "+1"
                            let newPhoneNumberText = usaCCPattern + numbersOnly
                            print("   ~~~> Replacing `\(phoneNumberText)`: \(numbersOnly) to \(newPhoneNumberText)")

                            mutableContact.phoneNumbers[index] = CNLabeledValue(
                                label: phoneNumber.label ?? CNLabelPhoneNumberMain,
                                value:CNPhoneNumber(stringValue: newPhoneNumberText)
                            )

                            let saveRequest = CNSaveRequest()
                            saveRequest.update(mutableContact)
                            try contactStore.execute(saveRequest)
                        }
                    }
                }
            } catch {
                print("Error updating contact: \(error)")
            }
        }
    }
}
