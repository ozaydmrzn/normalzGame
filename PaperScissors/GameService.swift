//
//  GameService.swift
//  PaperScissors
//
//  Created by Ozay Demirezen on 29/8/24.
//

import Foundation
import SwiftUI
import Firebase

class GameService: ObservableObject {
    private let functionUrl = "https://us-central1-normalz-dbe99.cloudfunctions.net/normalzGame"

    func fetchQuestion(completion: @escaping (Result<Question, Error>) -> Void) {
        guard let url = URL(string: functionUrl) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                print("No data received from server")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let question = try decoder.decode(Question.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(question))
                }
            } catch {
                print("Error decoding question: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Received JSON: \(jsonString)")
                }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    func submitAnswer(questionId: String, selectedOption: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: functionUrl) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["questionId": questionId, "selectedOption": selectedOption]
        do {
            request.httpBody = try JSONEncoder().encode(body)
            print("Sending request with body: \(body)") // Add this line for local logging
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }

            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = jsonResult["message"] as? String {
                    print("Received response: \(jsonResult)")
                    DispatchQueue.main.async {
                        completion(.success(message))
                    }
                } else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])
                }
            } catch {
                print("Error parsing response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

struct Question: Codable {
    let questionId: String
    let options: [String]
    var answerCounts: [String: Int]
    var totalAnswers: Int

    enum CodingKeys: String, CodingKey {
        case questionId
        case options
        case answerCounts
        case totalAnswers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        questionId = try container.decode(String.self, forKey: .questionId)
        options = try container.decode([String].self, forKey: .options)
        answerCounts = try container.decodeIfPresent([String: Int].self, forKey: .answerCounts) ?? [:]
        totalAnswers = try container.decodeIfPresent(Int.self, forKey: .totalAnswers) ?? 0
    }

    init(questionId: String, options: [String], answerCounts: [String : Int], totalAnswers: Int) {
        self.questionId = questionId
        self.options = options
        self.answerCounts = answerCounts
        self.totalAnswers = totalAnswers
    }
}

struct AnswerResponse: Codable {
    let message: String
    let newAnswerCounts: [String: Int]
    let newTotal: Int
}
