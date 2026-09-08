//
//  MeiliViewController.swift
//  meili_flutter_car_ios
//
//  Created by Henrique Marques on 01/08/2024.
//

import Foundation
import MeiliCarSDK
import UIKit
import SwiftUI

class MeiliViewController: UIViewController {
    var meiliParams: MeiliCarParams?
    
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
    
    var params: MeiliCarParams
    
    private var paramsWithDismiss: MeiliCarParams {
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
        return MeiliCarView(with: paramsWithDismiss)
    }
}
