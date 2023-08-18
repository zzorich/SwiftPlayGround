import Foundation

protocol AsyncLooper: Actor {
    var name: String { get }
    var excutor: UnownedSerialExecutor { get }
    func loop()
}

extension AsyncLooper {
    var excutor: UnownedSerialExecutor { unownedExecutor }
    func loop() {
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
    nonisolated func nonLocalLoop() {
        (1...100).forEach { _ in
            print("Nonlocal actor is running on Main Thread? \(Thread.isMainThread)")
        }
    }
}

extension MainActor: AsyncLooper {
    var name: String { "Main looper" }
}

func loop() async {
    (1...10).forEach { _ in
        print("No actor context is running on Main Thread? \(Thread.isMainThread)")
    }
}

//async let _ = LocalLooper.shared.loop()
//async let _ = MainActor.shared.loop()

// Should not in MainActor
//Task.detached {
//    (1...100).forEach { _ in
//        print("No actor context and detached is running on Main Thread? \(Thread.isMainThread)")
//    }
//}

// Is Playground in MainActor ?? may or may not
// Weired behaviour, below task some times will be excuted in main actor, some times will not, it appears choice is random
Task {
    (1...10).forEach { _ in
        print("No actor context and not detached is running on Main Thread? \(Thread.isMainThread)")
    }
}

async let _ = LocalLooper.shared.nonLocalLoop()
//async let _ = loop()
////async let _ = loop()
//Task {
//    await loop()
//}
// note: nonisloated excution sometimes will interleave with detached excution, they may not share excutor.
