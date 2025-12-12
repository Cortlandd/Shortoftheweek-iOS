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
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
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
