//
//  modelData.swift
//  Mi Salud
//
//  Created by Nico Trevino on 13/10/24.
//

import Foundation
import CoreML

// Function to compare user tags with event tags using the model and tag frequencies
func eventsCompatibility(userTags: [String], userTagFrequencies: [Int], eventTags: [String]) -> Double? {
    var totalCompatibility: Double = 0.0
    var totalFrequency: Int = 0

    for (index, userTag) in userTags.enumerated() {
        let frequency = userTagFrequencies[index]
        for eventTag in eventTags {
            if let prediction = testModel(userTag: userTag, eventTag: eventTag) {
                // Accumulate the compatibility weighted by the tag frequency
                totalCompatibility += prediction.Similarity * Double(frequency)
                totalFrequency += frequency
            }
        }
    }

    // Return the weighted average compatibility score
    if totalFrequency > 0 {
        return totalCompatibility / Double(totalFrequency)
    } else {
        return nil
    }
}

// Modified testModel function to accept userTag and eventTag as inputs
func testModel(userTag: String, eventTag: String) -> EventsCompatibilityFinalOutput? {
    do {
        let config = MLModelConfiguration()
        let model = try EventsCompatibilityFinal(configuration: config)

        // Provide the two tags to the model
        let input = EventsCompatibilityFinalInput(
            Tag1: userTag,
            Tag2: eventTag
        )

        let prediction = try model.prediction(input: input)

        return prediction
    } catch {
        print("Error in model prediction: \(error)")
        return nil
    }
}

