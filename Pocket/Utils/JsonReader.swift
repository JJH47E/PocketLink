// https://stackoverflow.com/a/74493509

import Foundation

class JsonReader<T> where T: Decodable {
    static func loadData(from file: URL) -> T? {
        do {
            if let data = FileManager.default.contents(atPath: file.path) {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let results = try decoder.decode(T.self, from: data)
                return results
            }
        } catch {
            print("[JsonReader] Error loading data from \(file.absoluteString). Detail: \(error)")
        }

        return nil
    }
}
