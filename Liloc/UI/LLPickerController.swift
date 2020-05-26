//
//  LLPickerController.swift
//  Liloc
//
//  Created by William Ma on 5/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

protocol LLPickerControllerDelegate: AnyObject {

    func pickerController(_ pickerController: LLPickerController, didSelectItems items: [LLPickerController.Item])

}

class LLPickerController: UIViewController {

    struct Style {
        let showImage: Bool
    }

    struct Item {
        let section: String

        let item: Any

        let imageView: Bool
        let title: String
        let subtitle: String
    }

    private let style: Style

    private var navigation: UINavigationController!
    private var content: LLPickerContentController!

    init(style: Style) {
        self.style = style

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        content = LLPickerContentController(pickerController: self)
        navigation = UINavigationController(rootViewController: content)
        addChild(navigation)
        view.addSubview(navigation.view)
        navigation.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        navigation.didMove(toParent: self)
    }

}

private class LLPickerContentController: UIViewController {

    weak var pickerController: LLPickerController?

    init(pickerController: LLPickerController) {
        self.pickerController = pickerController

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}

