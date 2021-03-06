import Foundation
import Domain
import RxSwift

final class AllPostsUseCase: Domain.AllPostsUseCase {
    private let network: PostsNetwork
    private let cache: AbstractCache<Post>

    init(network: PostsNetwork, cache: AbstractCache<Post>) {
        self.network = network
        self.cache = cache
    }

    func posts() -> Observable<[Post]> {
        let fetchPosts = cache.fetchObjects().asObservable()
        let stored = network.fetchPosts()
            .flatMap {
                return self.cache.save(objects: $0)
                    .asObservable()
                    .map(to: [Post].self)
                    .concat(Observable.just($0))
            }
        
        return fetchPosts.concat(stored)
    }
}

struct MapFromNever: Error {}
extension ObservableType where E == Never {
    func map<T>(to: T.Type) -> Observable<T> {
        return self.flatMap { _ in
            return Observable<T>.error(MapFromNever())
        }
    }
}
