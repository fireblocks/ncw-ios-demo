//
//  EndFlowFeedbackView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 16/01/2024.
//

import SwiftUI

struct EndFlowFeedbackView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager

    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 0) {
                Image(viewModel.didFail ? .feedbackFailure : .feedbackSuccess)
                    .padding(.top, 12)
                    .padding(.bottom, 24)

                if let title = viewModel.title {
                    Text(title)
                        .font(.h2)
                        .padding(.bottom, 16)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                
                if let subtitle = viewModel.subTitle {
                    Text(subtitle)
                        .font(.b1)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                if let content = viewModel.content {
                    content
                        .padding(.top, 32)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                
                if let action = viewModel.actionButton {
                    Button {
                        action()
                    } label: {
                        HStack {
                            Spacer()
                            if let icon = viewModel.buttonIcon {
                                Image(uiImage: icon)
                            }
                            if let title = viewModel.buttonTitle {
                                Text(title)
                                    .font(.b1)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .contentShape(.rect)
                        
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial, in: .capsule)
                    .contentShape(.rect)

                }
                
                if viewModel.didFail {
                    if !viewModel.items.isEmpty {
                        ShareLink(items: viewModel.items) {
                            Text("Share Logs")
                                .font(.b1)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.secondary)
                                .contentShape(.rect)
                        }
                        .tint(.secondary)
                    }
                }
                
                if let subAction = viewModel.subActionButton, let subTitle = viewModel.subButtonTitle {
                    Button {
                        subAction()
                    } label: {
                        Text(subTitle)
                            .font(.b1)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.secondary)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.borderless)
                    .tint(.secondary)
                }

            }
            .padding(16)

        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    (viewModel.rightToolbarItemAction ?? {})()
                } label: {
                    Image(viewModel.rightToolbarItemIcon ?? "")
                }
                .opacity(viewModel.rightToolbarItemAction != nil ? 1 : 0)
                .tint(.secondary)
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.navigationBarTitle)
                    .foregroundStyle(.secondary)
            }
            if viewModel.canGoBack {
                ToolbarItem(placement: .topBarLeading) {
                    CustomBackButtonView()
                }
            }
        }
//        .navigationTitle(viewModel.navigationBarTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
//        .navigationBarItems(leading: CustomBackButtonView())
        .interactiveDismissDisabled()

    }

}

#Preview() {
    #if EW
    NavigationContainerView(mockManager: EWManagerMock()) {
        SuccessView()
    }
    #else
    NavigationContainerView() {
        SuccessView()
    }
    #endif
}

#Preview() {
    #if EW
    NavigationContainerView(mockManager: EWManagerMock()) {
        FailureView()
    }
    #else
    NavigationContainerView() {
        FailureView()
    }
    #endif
}

struct SuccessView: View {
    var body: some View {
        SpinnerViewContainer {
            EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(
                title: LocalizableStrings.generateKeysSuccessDescription,
                navigationBarTitle: LocalizableStrings.generateKeysSuccessTopBarTitle,
                buttonTitle: LocalizableStrings.backupYourKeys,
                actionButton: {
                    print("action")
                },
                subButtonTitle: LocalizableStrings.illDoThisLater,
                subActionButton: {
                    print("sub action clicked")
                },
                didFail: false,
                canGoBack: false,
            ))
        }
    }
}

struct FailureView: View {
    var body: some View {
        NavigationStack {
            SpinnerViewContainer {
                EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(
                    icon: AssetsIcons.addDeviceImage.rawValue,
                    title: "Couldn't add device",
                    subTitle: "The process was canceled.",
                    navigationBarTitle: "Add Device",
                    buttonIcon: AssetsIcons.addNewDevice.getIcon(),
                    buttonTitle: "Go Home",
                    actionButton: {
                        print("action")
                    },
                    rightToolbarItemIcon: "settings",
                    rightToolbarItemAction: {
                        print("settings")
                    },
                    didFail: true,
                    content: AnyView(ValidateRequestIdTimeOutView())
                ))
            }
        }
    }
}
