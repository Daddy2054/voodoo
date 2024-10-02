//
//  main.swift
//  toodoo
//
//  Created by Jean on 22/08/24.
//

import Foundation

struct Todo: CustomStringConvertible, Codable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var description: String {
        return "\(isCompleted ? "👌" : "⏳") \(title)"
    }
}


class TodosManager {
    var todos = [Todo]()
    var cache: Cache
    
    init(cache: Cache) {
        self.cache = cache
        todos = cache.load() ?? []
    }
    // func addTodo
    
    func addTodo(with title: String){
        let todo = Todo(title: title)
        todos.append(todo)
        print(cache.save(todos: todos) ? "new todo saved successfully" : "new todo was not saved")
    }
    // func listTodo
    func listTodos() {
        for (index, todo) in todos.enumerated() {
            print("\(index + 1). \(todo)")
        }
    }
    // func toggleTodo
    func toggleCompletion(forTodoAtIndex index: Int) {
        index > 0 && index <= todos.count ?
        todos[index-1].isCompleted.toggle() :
        print("enter a valid number")
        _ = cache.save(todos: todos)
    }
    // func deleteTodo
    func deleteTodo(atIndex index: Int ) {
        index > 0 && index <= todos.count ?
        _ = todos.remove(at: index-1) :
        print("enter a valid number")
        _ = cache.save(todos: todos)
    }
}

class App {
    
    enum Command: String {
        case add
        case list
        case toggle
        case delete
        case exit
    }
    
    func run() {
        print("Todo App")
        let manager = TodosManager(cache: FileSystemCache())

       while true {
            print("enter command (add, list, toggle, delete, exit): ")
            let  command = Command(rawValue: readLine()?
                .trimmingCharacters(in:
                        .whitespacesAndNewlines)
                    .lowercased() ?? "")
            
            switch command {
            case .add:
                print("enter title:")
                if let title = readLine() {
                    manager.addTodo(with: title)
                }
            case .list:
                manager.listTodos()
            case .toggle:
                print("enter index:")
                if let index = Int(readLine() ?? "") {
                    manager.toggleCompletion(forTodoAtIndex: index)
                }
            case .delete:
                print("enter index:")
                if let index = Int(readLine() ?? "") {
                    manager.deleteTodo(atIndex: index)
                }
            case .exit:
                exit(0)
            default:
                print("wrong command!")
            }}}
}

protocol Cache {
    func save(todos: [Todo]) -> Bool
    func load() -> [Todo]?
}

class FileSystemCache: Cache {
    
    private let fileURL: URL

    init() {
        // Define the file path in the user's document directory
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("todos.json")
    }

    func save(todos: [Todo])  -> Bool {
        do {
            let data = try JSONEncoder().encode(todos)
            try data.write(to: fileURL)
            return true
        } catch {
            print("Error saving todos: \(error)")
            return false
        }
    }

    func load() -> [Todo]? {
        do {
            let data = try Data(contentsOf: fileURL)
            let todos = try JSONDecoder().decode([Todo].self, from: data)
            print("Todos loaded successfully!")
            return todos
        } catch {
            print("Error loading todos: \(error)")
            return nil
        }
    }
}
final class InMemoryCache: Cache {
    
    private var todos: [Todo] = []
    
   func save(todos: [Todo]) -> Bool{
        self.todos = todos
        return true
    }
    
    func load() -> [Todo]? {
        return todos.isEmpty ? nil : todos
    }
}

let app = App()
app.run()
