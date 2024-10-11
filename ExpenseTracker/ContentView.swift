import SwiftUI

struct ContentView: View {
    @AppStorage("totalAmount") private var totalAmount: Double = 0.0 // Persistent total amount
    @AppStorage("expenses") private var storedExpenses: Data = Data() // Persistent storage for expenses
    @State private var expenses: [Expense] = [] // Empty list of expenses (loaded from storage)
    @State private var expenseName: String = ""
    @State private var expenseCost: String = ""
    @State private var newTotalAmount: String = "" // Input for new total amount
    @State private var addAmountValue: String = "" // Input for adding amount
    @State private var showAmountSection: Bool = false // Toggle visibility for "Set/Add Amount" section
    
    var body: some View {
        VStack {
            // Button with "$" sign centered inside green dot to toggle amount settings
            HStack {
                Button(action: {
                    showAmountSection.toggle() // Toggle visibility of the section
                }) {
                    ZStack {
                        Image(systemName: "circle.fill") // Green dot
                            .foregroundColor(.green)
                            .frame(width: 30, height: 30) // Adjust size of the dot
                        Text("$") // Centered "$" sign
                            .foregroundColor(.black) // Make the "$" black
                            .font(.system(size: 16, weight: .bold)) // Adjust font size and weight
                    }
                }
                .padding()
                Spacer()
            }
            
            if showAmountSection {
                // Section for "Set Amount" and "Add Amount"
                VStack {
                    HStack {
                        TextField("Enter new total amount", text: $newTotalAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        Button(action: {
                            if let amount = Double(newTotalAmount) {
                                setTotalAmount(amount: amount)
                            }
                        }) {
                            Text("Set Amount")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    HStack {
                        TextField("Enter amount to add", text: $addAmountValue)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        Button(action: {
                            if let amount = Double(addAmountValue) {
                                addToTotalAmount(amount: amount)
                            }
                        }) {
                            Text("Add Amount")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    Button(action: {
                        deleteAllExpenses()
                    }) {
                        Text("Delete List")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            
            // Display the total remaining amount
            Text("Remaining: $\(totalAmount, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // Expense entry fields
            HStack {
                TextField("Expense", text: $expenseName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("$", text: $expenseCost)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                Button(action: {
                    if let cost = Double(expenseCost) {
                        addExpense(name: expenseName, cost: cost)
                    }
                }) {
                    Text("Add")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            // Expenses list (showing latest added first)
            List(expenses.reversed()) { expense in
                HStack {
                    Text(expense.name)
                    Spacer()
                    Text("$\(expense.cost, specifier: "%.2f")")
                }
            }
        }
        .padding()
        .onAppear {
            loadExpenses() // Load saved expenses on app start
        }
    }
    
    // Function to add an expense
    func addExpense(name: String, cost: Double) {
        let newExpense = Expense(name: name, cost: cost)
        expenses.append(newExpense)
        saveExpenses() // Save the updated list of expenses
        totalAmount -= cost
        expenseName = "" // Clear the input fields
        expenseCost = ""
    }
    
    // Function to set a new total amount
    func setTotalAmount(amount: Double) {
        totalAmount = amount
        newTotalAmount = "" // Clear the input field
    }
    
    // Function to add to the current total amount
    func addToTotalAmount(amount: Double) {
        totalAmount += amount
        addAmountValue = "" // Clear the input field
    }
    
    // Function to delete all expenses
    func deleteAllExpenses() {
        expenses.removeAll() // Clear all expenses
        saveExpenses() // Update saved data
    }
    
    // Save expenses to persistent storage
    func saveExpenses() {
        do {
            let encoded = try JSONEncoder().encode(expenses)
            storedExpenses = encoded
        } catch {
            print("Failed to save expenses: \(error.localizedDescription)")
        }
    }
    
    // Load expenses from persistent storage
    func loadExpenses() {
        do {
            expenses = try JSONDecoder().decode([Expense].self, from: storedExpenses)
        } catch {
            print("Failed to load expenses: \(error.localizedDescription)")
        }
    }
}

// Expense model
struct Expense: Identifiable, Codable {
    var id = UUID()
    var name: String
    var cost: Double
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
