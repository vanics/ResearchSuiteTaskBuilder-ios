//
//  ViewController.swift
//  ResearchSuiteTaskBuilder
//
//  Created by jdkizer9 on 01/09/2017.
//  Copyright (c) 2017 jdkizer9. All rights reserved.
//

import UIKit
import ResearchSuiteTaskBuilder
import ResearchKit

class ViewController: UIViewController, ORKTaskViewControllerDelegate {
    
    var taskBuilder: RSTBTaskBuilder!
    
    var taskFinishedHandler: ((ORKTaskViewController) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stepGeneratorServices: [RSTBStepGenerator] = [
            RSTBInstructionStepGenerator(),
            RSTBTextFieldStepGenerator(),
            RSTBIntegerStepGenerator(),
            RSTBSingleChoiceStepGenerator(),
            RSTBMultipleChoiceStepGenerator(),
            RSTBTimePickerStepGenerator(),
            RSTBFormStepGenerator(),
            RSTBBooleanStepGenerator(),
            RSTBPasscodeStepGenerator(),
            RSTBLocationStepGenerator(),
            RSTBScaleStepGenerator(),
            RSTBDefaultStepGenerator()
        ]
        
        let answerFormatGeneratorServices: [RSTBAnswerFormatGenerator] = [
            RSTBTextFieldStepGenerator(),
            RSTBIntegerStepGenerator(),
            RSTBTimePickerStepGenerator(),
            RSTBSingleChoiceStepGenerator(),
            RSTBMultipleChoiceStepGenerator(),
            RSTBLocationStepGenerator(),
            RSTBBooleanStepGenerator()
        ]
        
        let elementGeneratorServices: [RSTBElementGenerator] = [
            RSTBElementListGenerator(),
            RSTBElementFileGenerator(),
            RSTBElementSelectorGenerator()
        ]
        
        let taskGenerators: [RSTBTaskGenerator.Type] = [
            RSTBOrderedTaskGenerator.self
        ]
        
        // Do any additional setup after loading the view, typically from a nib.
        self.taskBuilder = RSTBTaskBuilder(
            stateHelper: nil,
            elementGeneratorServices: elementGeneratorServices,
            stepGeneratorServices: stepGeneratorServices,
            answerFormatGeneratorServices: answerFormatGeneratorServices,
            taskGeneratorServices: taskGenerators
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        taskFinishedHandler?(taskViewController)
        
        
    }
    
    func runTask(task: ORKTask) {
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = self
        
        self.taskFinishedHandler = { [unowned self] taskViewController in
            
            print("finished!!")
            
            let result: ORKTaskResult = taskViewController.result
            if let stepResult = result.stepResult(forStepIdentifier: "location"),
                let locationResult = stepResult.firstResult as? ORKLocationQuestionResult,
                let location = locationResult.locationAnswer {
                print(location.coordinate)
                print(location.addressDictionary)
                print(location.userInput)
                print(location.region)
            }
            
            print((result.stepResult(forStepIdentifier: "location")?.firstResult as? ORKLocationQuestionResult))
            
            if let stepResultsJSON = self.taskBuilder.processResult(result: result, forElementFilename: "sample") {
                
                print(stepResultsJSON)
                taskViewController.dismiss(animated: true, completion: nil)
                
            }
            else {
                taskViewController.dismiss(animated: true, completion: nil)
            }
            
        }
        
        self.present(taskViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func sampleTaskButtonPressed(_ sender: Any) {
//        if let steps = self.stepBuilder.steps(forElementFilename: "sample") {
//            let task = ORKOrderedTask(identifier: "sample", steps: steps)
//            self.runTask(task: task)
//        }
        
        if let task = self.taskBuilder.task(forElementFilename: "sampleTask") {
            self.runTask(task: task)
        }
    }
    
}

