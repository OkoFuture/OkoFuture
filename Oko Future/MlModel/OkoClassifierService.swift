//
//  OkoClassifierService.swift
//  Oko Future
//
//  Created by Денис Калинин on 10.05.23.
//

import UIKit
import Vision

struct ClassifierResultModel {
  let identifier: String
  let confidence: Int
  
  var description: String {
    return "This is \(identifier) with \(confidence)% confidence"
  }
}

enum ImageClassifierServiceState {
  case startRequest, requestFailed, receiveResult(resultModel: ClassifierResultModel)
}

class OkoClassifierService {
  var onDidUpdateState: ((ImageClassifierServiceState) -> Void)?
  
  func classifyImage(_ pixelBuffer: CVPixelBuffer) {
    onDidUpdateState?(.startRequest)
    
    guard let model = makeImageClassifierModel() else {
      onDidUpdateState?(.requestFailed)
      return
    }
      makeClassifierRequest(for: model, pixelBuffer: pixelBuffer)
  }
  
  private func makeImageClassifierModel() -> VNCoreMLModel? {
      
      let config = MLModelConfiguration()
      let model = try! OkoClassifier2(configuration: config)
      let mlModel = try! VNCoreMLModel(for: model.model)
      return mlModel
  }
  
    private func makeClassifierRequest(for model: VNCoreMLModel, /*ciImage: CIImage*/ pixelBuffer: CVPixelBuffer) {
    let request = VNCoreMLRequest(model: model) { [weak self] request, error in
      self?.handleClassifierResults(request.results)
    }
    
//    let handler = VNImageRequestHandler(ciImage: ciImage)
    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
    DispatchQueue.global(qos: .userInteractive).async {
      do {
        try handler.perform([request])
      } catch {
        self.onDidUpdateState?(.requestFailed)
      }
    }
  }
  
  private func handleClassifierResults(_ results: [Any]?) {
    guard let results = results as? [VNClassificationObservation],
      let firstResult = results.first else {
      onDidUpdateState?(.requestFailed)
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      let confidence = (firstResult.confidence * 100).rounded()
      let resultModel = ClassifierResultModel(identifier: firstResult.identifier, confidence: Int(confidence))
      self?.onDidUpdateState?(.receiveResult(resultModel: resultModel))
    }
  }
}
