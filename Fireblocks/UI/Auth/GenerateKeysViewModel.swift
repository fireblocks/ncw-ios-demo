//
//  GenerateKeysViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 06/02/2025.
//

import Foundation
import SwiftUI
import FirebaseAuth
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

//protocol MpcKeysViewModelDelegate: AnyObject {
//    func configSuccessUI()
//    func showAlertMessage(message: String)
//}

extension GenerateKeysView {
    class ViewModel: ObservableObject {
        private var coordinator: Coordinator?
        private var loadingManager: LoadingManager?
        private var fireblocksManager: FireblocksManager?
        private var mpcKeyTask: Task<Void, Never>?

        var didSucceedGenerateKeys = false
//        weak var delegate: MpcKeysViewModelDelegate?
           
        deinit {
            cancelTasks()
        }
        
        func setup(loadingManager: LoadingManager, fireblocksManager: FireblocksManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.fireblocksManager = fireblocksManager
            self.coordinator = coordinator
        }

        @MainActor
        func generateMpcKeys() {
            guard let fireblocksManager else { return }
            self.loadingManager?.setLoading(value: true)
            mpcKeyTask = Task {
                do {
                    let result = try await fireblocksManager.generateMpcKeys()
                    handleResult(result: result)
                } catch {
                    self.loadingManager?.setAlertMessage(error: error)
                }
            }
        }
        
        @MainActor
        func generateEDDSAKeys() {
            guard let fireblocksManager else { return }
            self.loadingManager?.setLoading(value: true)
            mpcKeyTask = Task {
                do {
                    let result = try await fireblocksManager.generateEDDSAKeys()
                    handleResult(result: result)
                } catch {
                    self.loadingManager?.setAlertMessage(error: error)
                }
            }
        }
        
        @MainActor
        func generateECDSAKeys() {
            guard let fireblocksManager else { return }
            self.loadingManager?.setLoading(value: true)
            mpcKeyTask = Task {
                do {
                    let result = try await fireblocksManager.generateECDSAKeys()
                    handleResult(result: result)
                } catch {
                    self.loadingManager?.setAlertMessage(error: error)
                }
            }
        }
        
        private func handleResult(result: Set<KeyDescriptor>) {
            DispatchQueue.main.async {
                let isGenerated = result.filter({$0.keyStatus == .READY}).count > 0
                AppLoggerManager.shared.logger()?.log("FireblocksManager, generateMpcKeys() isGenerated value: \(isGenerated).")
                self.loadingManager?.setLoading(value: false)
                if isGenerated {
                    self.fireblocksManager?.startPolling()
                    self.createAssets()
                    
                    let viewModel: EndFlowFeedbackView.ViewModel
                    viewModel = EndFlowFeedbackView.ViewModel(
                        icon: nil,
                        title: LocalizableStrings.generateKeysSuccessDescription,
                        navigationBarTitle: LocalizableStrings.generateKeysSuccessTopBarTitle,
                        buttonIcon: nil,
                        buttonTitle: LocalizableStrings.backupYourKeys,
                        actionButton: {
                            self.coordinator?.path.append(NavigationTypes.backup(true))
                        },
                        subButtonTitle: LocalizableStrings.illDoThisLater,
                        subActionButton: {
                            SignInViewModel.shared.launchView = NavigationContainerView {
                                TabBarView()
                            }
                        },
                        rightToolbarItemIcon: "settings",
                        rightToolbarItemAction: {
                            self.coordinator?.path.append(NavigationTypes.settings)
                        },
                        didFail: false,
                        canGoBack: false)
                    
                    self.coordinator?.path.append(NavigationTypes.feedback(viewModel))                    
                } else {
                    let error = FireblocksManager.shared.getError(.generateKeys, defaultError: CustomError.generateKeys)
                    self.loadingManager?.setAlertMessage(error: error)
                }
            }
        }
        
        private func cancelTasks() {
            mpcKeyTask?.cancel()
            mpcKeyTask = nil
        }
        
        func createAssets(){
            didSucceedGenerateKeys = true
//            self.delegate?.configSuccessUI()
        }
        
        func isKeysGenerated(isGenerated: Bool, error: String? = nil) {
            if isGenerated {
                self.createAssets()
            } else {
//                self.delegate?.showAlertMessage(message: error ?? LocalizableStrings.mpcKeysGenerationFailed)
            }
        }

    }
}
