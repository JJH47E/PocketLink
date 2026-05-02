// https://stackoverflow.com/a/74493509

import Foundation

class JsonReader<T> where T: Decodable {
    static func loadData(from file: URL) -> T? {
        do {
            if let data = FileManager.default.contents(atPath: file.path) {
                return try JSONDecoder.snakeCase.decode(T.self, from: data)
            }
        } catch {
            // silently return nil; callers handle missing/malformed files
        }
        return nil
    }
}
