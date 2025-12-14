//
//  FilmDetailReducer.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct FilmDetailReducer {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public var film: Film
        
        public var isBookmarked: Bool = false
        public var isUpdatingBookmark: Bool = false
        public var errorMessage: String?
        
        var blocks: [ArticleBlock] = []
        var isParsing = false
        
        public init(
            film: Film,
            isBookmarked: Bool = false,
            isUpdatingBookmark: Bool = false,
            errorMessage: String? = nil
        ) {
            self.film = film
            self.isBookmarked = isBookmarked
            self.isUpdatingBookmark = isUpdatingBookmark
            self.errorMessage = errorMessage
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case bookmarkTapped
        case clearErrorTapped
        case detailDismissed
        case parsedBlocks([ArticleBlock])
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isParsing = true
                let html = state.film.articleHTML.wrappingNormalized
                return .run { send in
                    let blocks = await Task.detached(priority: .userInitiated) {
                        await ArticleParser.parse(html)
                    }.value
                    await send(.parsedBlocks(blocks))
                }
            case .parsedBlocks(let blocks):
              state.isParsing = false
              state.blocks = blocks
              return .none
            case .bookmarkTapped:
                return .none
            case .detailDismissed:
                return .none
            case .clearErrorTapped:
                return .none
            default:
                return .none
            }
        }
    }
    
}
