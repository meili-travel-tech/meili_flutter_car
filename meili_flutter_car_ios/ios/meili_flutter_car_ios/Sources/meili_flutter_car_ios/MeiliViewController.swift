//
//  MeiliViewController.swift
//  meili_flutter_ios
//
//  Created by Henrique Marques on 01/08/2024.
//

import Foundation
import MeiliSDK
import UIKit
import SwiftUI

class MeiliViewController: UIViewController {
    var meiliParams: MeiliParams?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let meiliParams = meiliParams {
            let meiliView = MeiliWrapperView(params: meiliParams)

            let hostingController = UIHostingController(rootView: meiliView)
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            hostingController.didMove(toParent: self)
        }
    }
}


struct MeiliWrapperView: View {
    @Environment(\.dismiss) private var dismiss
    
    var params: MeiliParams
    
    private var paramsWithDismiss: MeiliParams {
        var _params = self.params
        _params.dismissAction = {
            dismiss()
            MeiliEventDispatcher.shared.sendDismissed()
        }
        _params.onEndBookingFlow = { popToRoot in
            MeiliEventDispatcher.shared.sendBookingFlowEnded(popToRoot)
        }
        return _params
    }
    
    var body: some View {
        return MeiliView(with: paramsWithDismiss)
    }
}
