//
//  ViewController.swift
//  WWDC
//
//  Created by Benjamin Herzog on 29.03.17.
//  Copyright © 2017 Benjamin Herzog. All rights reserved.
//

import UIKit

public class ViewController: UIViewController {
    
    lazy var input: String = {
        guard let path = Bundle.main.path(forResource: "test", ofType: "txt") else {
            fatalError("Could not find test.txt in Bundle!")
        }
        
        return (try? String(contentsOfFile: path)) ?? ""
    }()
    
    var textView: UITextView!
    private let generator = Generator()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.jsEvaluator.run(script: "const a = \"hello\"; alert(a)")
        
        self.navigationController?.navigationBar.tintColor = UIColor(r: 115, g: 115, b: 115, a: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(r: 213, g: 213, b: 213, a: 1)
      
        let run = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(evaluate))
        
        self.navigationItem.rightBarButtonItem = run
        self.title = "WWDC - Benjamin Herzog"
        
        let insets = UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 8)
        self.textView = UITextView(frame: UIEdgeInsetsInsetRect(self.view.bounds, insets))
        self.textView.autocapitalizationType = .none
        self.textView.autocorrectionType = .no
        self.textView.alwaysBounceVertical = true
        self.textView.keyboardDismissMode = .interactive
        self.textView.keyboardAppearance = .dark
        self.textView.delegate = self
        self.textView.backgroundColor = UIColor(r: 31, g: 32, b: 41, a: 1)
        self.view.backgroundColor = self.textView.backgroundColor
        
        self.textView.text = self.input
        self.textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.textView)
        self.updateText(text: self.textView.text)
    }
    
    func evaluate() {
        do {
            let parser = Parser(input: self.textView.text)
            let program = try parser.parseProgram()
            let js = self.generator.generate(program: program)
            JSEvaluator.run(controller: self, script: js)
        } catch {
            let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

}

extension ViewController: UITextViewDelegate {
    
    static let throttle: TimeInterval = 0.05
    
    public func textViewDidChange(_ textView: UITextView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(updateText), with: textView.text, afterDelay: ViewController.throttle)
    }
    
    func updateText(text: String) {
        let lexer = Lexer(input: text)
        let tokens = lexer.start()
        let range = textView.selectedRange
        textView.isScrollEnabled = false
        textView.attributedText = attributedString(tokens: tokens)
        textView.isScrollEnabled = true
        textView.selectedRange = range
    }
    
}
