//
//  DetailsListItemView.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 02/04/2025.
//
import SwiftUI

struct DetailsListItemView: View {
    @Environment(LoadingManager.self) var loadingManager
    var title: String?
    var attributedTitle: AttributedString?
    var contentText: String?
    var subContent: String? = nil
    var showCopyButton: Bool = false
    var contentColor: Color = .white
    var overflow: Text.TruncationMode = .middle

    var body: some View {
        HStack(spacing: 0) {
            if let attributedTitle = attributedTitle {
                Text(attributedTitle)
                    .frame(width: Dimens.cellTitleWidth, alignment: .leading)
                    .padding(.trailing, Dimens.paddingSmall)
            } else if let title = title {
                Text(title)
                    .font(.b2)
                    .foregroundStyle(.secondary)
                    .frame(width: Dimens.cellTitleWidth, alignment: .leading)
                    .padding(.trailing, Dimens.paddingSmall)
            }
                
            
            if let contentText = contentText {
                if let subContent = subContent {
                    VStack(alignment: .leading) {
                        Text(contentText)
                            .font(.b2)
                            .foregroundColor(contentColor)
                            .lineLimit(1)
                            .truncationMode(overflow)
                        Text(subContent)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text(contentText)
                        .font(.b2)
                        .foregroundColor(contentColor)
                        .lineLimit(1)
                        .truncationMode(overflow)
                }
            }
            Spacer()
            
            if showCopyButton {
                Button(action: {
                    UIPasteboard.general.string = contentText
                    loadingManager.toastMessage = "Copied!"

                }) {
                    Image(uiImage: AssetsIcons.copy.getIcon())
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Dimens.detailsListItemHeight)
        .padding(.horizontal, Dimens.paddingLarge)
    }
}

#Preview {
    DetailsListItemView(
        title: "Recipient",
        contentText: "0x324387ynckc83y48fhlc883mf",
        showCopyButton: true
    )
}
