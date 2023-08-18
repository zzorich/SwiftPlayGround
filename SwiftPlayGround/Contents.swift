import Foundation

protocol AsyncLooper: Actor {
    var name: String { get }
    var excutor: UnownedSerialExecutor { get }
    func loop() async
}

extension AsyncLooper {
    var excutor: UnownedSerialExecutor { unownedExecutor }
    func loop() async {
        (1...10).forEach { _ in
            print("\(name) is running on Main Thread? \(Thread.isMainThread)")
            //dump(excutor)
        }
    }
}


actor LocalLooper: AsyncLooper {
    var name = "local looper"
}

extension LocalLooper {
    static let shared = LocalLooper()
    // Where should you be ? MainActor ?
    nonisolated func nonLocalLoop() async {
        (1...100).forEach { _ in
            print("Nonlocal actor is running on Main Thread? \(Thread.isMainThread)")
        }
    }
}

extension MainActor: AsyncLooper {
    var name: String { "Main looper" }
}

func loop() async -> String {
    (1...10).forEach { _ in
        print("No actor context is running on Main Thread? \(Thread.isMainThread)")
    }
    return ""
}

//async let _ = LocalLooper.shared.loop()
//async let _ = MainActor.shared.loop()

// Should not in MainActor
Task.detached {
    (1...100).forEach { _ in
        print("No actor context and detached is running on Main Thread? \(Thread.isMainThread)")
    }
}

// Is Playground in MainActor ??
//Task {
//    (1...10).forEach { _ in
//        print("No actor context and not detached is running on Main Thread? \(Thread.isMainThread)")
//    }
//}

async let _ = LocalLooper.shared.nonLocalLoop()
// note: nonisloated excution will interleave with detached excution, they do not share excutor.
