//
//  ReminderInputView.swift
//  RightNow
//
//  Created by iMoe on 2020/1/16.
//  Copyright © 2020 imoe. All rights reserved.
//

import Cocoa

protocol ReminderInputViewDelegate: AnyObject {
    /// Invoked when the user pressed the return key.
    func reminderInputView(
        _ reminderInputView: ReminderInputView,
        textFieldDidEnter textField: AutoExpandingTextField)
    
    /// Invoked when the text inside the text field changed.
    func reminderInputView(
        _ reminderInputView: ReminderInputView,
        textFieldTextDidChange textField: AutoExpandingTextField)
}

extension ReminderInputViewDelegate {
    func reminderInputView(
        _ reminderInputView: ReminderInputView,
        textFieldDidEnter textField: AutoExpandingTextField
    ) { }
    
    func reminderInputView(
        _ reminderInputView: ReminderInputView,
        textFieldTextDidChange textField: AutoExpandingTextField
    ) { }
}


final class ReminderInputView: NSView {
    
    var viewModel = ViewModel() {
        didSet {
            renderViewModel()
        }
    }
    
    weak var delegate: ReminderInputViewDelegate?
    
    override var intrinsicContentSize: NSSize {
        contentStackView.intrinsicContentSize
    }
    
    weak var textField: AutoExpandingTextField!
    weak var label: NSTextField!
    weak var contentStackView: StackView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private extension ReminderInputView {
    @objc func textFieldDidEnter(_ sender: AutoExpandingTextField) {
        delegate?.reminderInputView(self, textFieldDidEnter: sender)
    }
    
    func setupInterface() {
        setContentHuggingPriority(.required, for: .vertical)
        
        let textField = createTextField()
        self.textField = textField
        
        let label = createLabel()
        self.label = label
        
        let borderView = createBorderView()
        
        let contentStackView = createContentStackView()
        addSubview(contentStackView, insets: .init())
        contentStackView.addArrangedSubview(label)
        contentStackView.addArrangedSubview(textField)
        contentStackView.addArrangedSubview(borderView)
        contentStackView.setCustomSpacing(12, after: label)
        self.contentStackView = contentStackView
    }
    
    func createTextField() -> AutoExpandingTextField {
        let textField = AutoExpandingTextField()
        textField.cell?.sendsActionOnEndEditing = false
        textField.target = self
        textField.action = #selector(textFieldDidEnter(_:))
        textField.isBordered = false
        textField.font = .systemFont(ofSize: 16)
        textField.focusRingType = .none
        textField.lineBreakMode = .byWordWrapping
        textField.usesSingleLineMode = false
        textField.maximumNumberOfLines = 0
        textField.cell?.wraps = true
        textField.cell?.usesSingleLineMode = false
        textField.delegate = self
        return textField
    }
    
    func createLabel() -> NSTextField {
        let label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = #colorLiteral(red: 0.525490284, green: 0.5568627715, blue: 0.5882352591, alpha: 1)
        return label
    }
    
    func createBorderView() -> NSView {
        let borderView = NSView()
        borderView.wantsLayer = true
        let borderColor = #colorLiteral(red: 0.9450982213, green: 0.9529412389, blue: 0.9607843757, alpha: 1)
        borderView.layer?.backgroundColor = borderColor.cgColor
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.addConstraint(.init(
            item: borderView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 1))
        return borderView
    }
    
    func createContentStackView() -> StackView {
        let contentStackView = StackView()
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.orientation = .vertical
        contentStackView.spacing = 4
        return contentStackView
    }
    
    func renderViewModel() {
        if textField.stringValue != viewModel.textFieldText {
            textField.stringValue = viewModel.textFieldText
        }
        
        if label.stringValue != viewModel.labelText {
            label.stringValue = viewModel.labelText
        }
        
        if textField.placeholderString != viewModel.textFieldPlaceholder {
            textField.placeholderString = viewModel.textFieldPlaceholder
        }
    }
}


extension ReminderInputView {
    struct ViewModel {
        var labelText: String = ""
        var textFieldText: String = ""
        var textFieldPlaceholder: String = ""
        var showIndicator: Bool = false
    }
}


extension ReminderInputView: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        let textField = obj.object as! AutoExpandingTextField
        textField.invalidateIntrinsicContentSize()
        viewModel.textFieldText = textField.stringValue
        delegate?.reminderInputView(
            self,
            textFieldTextDidChange: textField)
    }
}
