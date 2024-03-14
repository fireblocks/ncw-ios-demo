//
//  EndFlowFeedbackView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 16/01/2024.
//

import SwiftUI

struct EndFlowFeedbackView: View {
    @StateObject var viewModel: ViewModel
    var content: AnyView?

    init(viewModel: ViewModel, content: AnyView?) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.content = content
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GenericHeaderView(icon: viewModel.icon, title: viewModel.title, subtitle: viewModel.subTitle)

                content
                    .padding(.top, 32)

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
                                    .font(.body1)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                        
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .background(AssetsColors.primaryBlue.color())
                    .cornerRadius(16)
                    .tint(.primary)
                }
                
                if viewModel.didFail {
                    Button {
                        viewModel.shareLogs()
                    } label: {
                        HStack {
                            Text("Share Logs")
                                .font(.body1)
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                        
                    }
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(AssetsColors.primaryBlue.color())
                    .cornerRadius(16)
                    .padding(.top)
                }

            }
            .padding(16)

        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    (viewModel.rightToolbarItemAction ?? {})()
                } label: {
                    Image(viewModel.rightToolbarItemIcon ?? "")
                }
                .opacity(viewModel.rightToolbarItemAction != nil ? 1 : 0)
                .tint(.primary)
            }
        }
        .navigationTitle(viewModel.navigationBarTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .interactiveDismissDisabled()

    }

}

struct EndFlowFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(
                icon: AssetsIcons.addDeviceImage.rawValue,
                title: "Couldn't add device",
                subTitle: "The process was canceled.",
                navigationBarTitle: "Add Device",
                buttonIcon: AssetsIcons.home.getIcon(),
                buttonTitle: "Go home",
                actionButton: {
                    print("action")
                },
                rightToolbarItemIcon: "close",
                rightToolbarItemAction: {
                    print("close")
                }
            ), content: AnyView(ValidateRequestIdTimeOutView()))
        }
    }
}
