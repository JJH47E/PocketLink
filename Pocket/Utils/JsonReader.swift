// https://stackoverflow.com/a/74493509

import Foundation

class JsonReader<T> where T: Decodable {
    static func loadData(from file: URL) -> T? {
        do {
            if let data = FileManager.default.contents(atPath: file.path) {
                let results = try JSONDecoder().decode(T.self, from: data)
                return results
            }
        } catch {
            print("Error: \(error)")
        }

        return nil
    }
}
